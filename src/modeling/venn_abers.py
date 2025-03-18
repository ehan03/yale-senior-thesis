# standard library imports
from typing import Optional

# third party imports
import numpy as np
from sklearn.model_selection import StratifiedKFold

# local imports

np.seterr(divide="ignore", invalid="ignore")


class VennAbersCV:
    """Inductive (IVAP) or Cross (CVAP) Venn-ABERS prediction method for binary classification problems

    Implements the Inductive or Cross Venn-Abers calibration method as described in Sections 2-4 in [1]

    References
    ----------
    [1] Vovk, Vladimir, Ivan Petej, and Valentina Fedorova. "Large-scale probabilistic predictors
    with and without guarantees of validity."Advances in Neural Information Processing Systems 28 (2015).
    (arxiv version https://arxiv.org/pdf/1511.00213.pdf)

    Parameters
    ----------

    estimator : sci-kit learn estimator instance, default=None
        The classifier whose output need to be calibrated to provide more
        accurate `predict_proba` outputs.

    inductive : bool
        True to run the Inductive (IVAP) or False for Cross (CVAP) Venn-ABERS calibtration

    n_splits: int, default=5
        For CVAP only, number of folds. Must be at least 2.
        Uses sklearn.model_selection.StratifiedKFold functionality
        (https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.StratifiedKFold.html).

    cal_size : float or int, default=None
        For IVAP only, uses sklearn.model_selection.train_test_split functionality
        (https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.train_test_split.html).
        If float, should be between 0.0 and 1.0 and represent the proportion
        of the dataset to include in the proper training / calibration split.
        If int, represents the absolute number of test samples. If None, the
        value is set to the complement of the train size. If ``train_size``
        is also None, it will be set to 0.25.

    train_proper_size : float or int, default=None
        For IVAP only, if float, should be between 0.0 and 1.0 and represent the
        proportion of the dataset to include in the poroper training set split. If
        int, represents the absolute number of train samples. If None,
        the value is automatically set to the complement of the test size.

    random_state : int, RandomState instance or None, default=None
        Controls the shuffling applied to the data before applying the split.
        Pass an int for reproducible output across multiple function calls.

    shuffle : bool, default=True
        Whether to shuffle the data before splitting. For IVAP if shuffle=False
        then stratify must be None. For CVAP whether to shuffle each class’s samples
        before splitting into batches

    stratify : array-like, default=None
        For IVAP only. If not None, data is split in a stratified fashion, using this as
        the class labels.

    precision: int, default = None
        Optional number of decimal points to which Venn-Abers calibration probabilities p_cal are rounded to.
        Yields significantly faster computation time for larger calibration datasets
    """

    def __init__(
        self,
        estimator,
        n_splits: int = 5,
        random_state: Optional[int] = None,
        shuffle: bool = True,
        precision: Optional[int] = None,
    ):
        self.estimator = estimator
        self.n_splits = n_splits
        self.clf_p_cal = []
        self.clf_y_cal = []
        self.random_state = random_state
        self.shuffle = shuffle
        self.precision = precision

    def fit(self, _x_train, _y_train):
        """Fits the IVAP or CVAP calibrator to the training set.

        Parameters
        ----------
        _x_train : {array-like}, shape (n_samples,)
            Input data for calibration consisting of training set numerical features

        _y_train : {array-like}, shape (n_samples,)
            Associated binary class labels.
        """

        kf = StratifiedKFold(
            n_splits=self.n_splits,
            shuffle=self.shuffle,
            random_state=self.random_state,
        )
        for train_index, test_index in kf.split(_x_train, _y_train):
            self.estimator.fit(_x_train[train_index], _y_train[train_index].flatten())
            clf_prob = self.estimator.predict_proba(_x_train[test_index])
            self.clf_p_cal.append(clf_prob)
            self.clf_y_cal.append(_y_train[test_index])

        self._is_fitted = True

        return self

    def predict_proba(self, _x_test, p0_p1_output=False):
        """Generates Venn-ABERS calibrated probabilities.


        Parameters
        ----------
        _x_test : {array-like}, shape (n_samples,)
            Training set numerical features

        loss : str, default='log'
            Log or Brier loss. For further details of calculation
            see Section 4 in https://arxiv.org/pdf/1511.00213.pdf

        p0_p1_output: bool, default = False
            If True, function also returns p0_p1 binary probabilistic outputs

        Returns
        ----------
        p_prime: {array-like}, shape (n_samples,n_classses)
            Venn-ABERS calibrated probabilities

        p0_p1: {array-like}, default  = None
            Venn-ABERS calibrated p0 and p1 outputs (if p0_p1_output = True)
        """

        p0p1_test = []
        clf_prob_test = self.estimator.predict_proba(_x_test)
        for i in range(self.n_splits):
            va = VennAbers()
            va.fit(
                p_cal=self.clf_p_cal[i],
                y_cal=self.clf_y_cal[i],
                precision=self.precision,
            )
            _, probs = va.predict_proba(p_test=clf_prob_test)
            p0p1_test.append(probs)
        p0_stack = np.hstack([prob[:, 0].reshape(-1, 1) for prob in p0p1_test])
        p1_stack = np.hstack([prob[:, 1].reshape(-1, 1) for prob in p0p1_test])

        p_prime = np.zeros((len(_x_test), 2))
        p_prime[:, 1] = geo_mean(p1_stack) / (
            geo_mean(1 - p0_stack) + geo_mean(p1_stack)
        )
        p_prime[:, 0] = 1 - p_prime[:, 1]

        if p0_p1_output:
            p0 = 1 - geo_mean(1 - p0_stack)
            p1 = geo_mean(p1_stack)
            p0_p1 = np.hstack((p0.reshape(-1, 1), p1.reshape(-1, 1)))

            return p_prime, p0_p1
        else:
            return p_prime

    def __sklearn_is_fitted__(self):
        """
        Check fitted status and return a Boolean value.
        """

        # This is to make Scikit-learn stop complaining about not being fitted
        # when using the model in a pipeline
        return hasattr(self, "_is_fitted") and self._is_fitted


class VennAbers:
    """Implementation of the Venn-ABERS calibration for binary classification problems. Venn-ABERS calibration is a
    method of turning machine learning classification algorithms into probabilistic predictors
    that automatically enjoys a property of validity (perfect calibration) and is computationally efficient.
    The algorithm is described in [1].


    References
    ----------
    [1] Vovk, Vladimir, Ivan Petej, and Valentina Fedorova. "Large-scale probabilistic predictors
    with and without guarantees of validity."Advances in Neural Information Processing Systems 28 (2015).
    (arxiv version https://arxiv.org/pdf/1511.00213.pdf)

    .. versionadded:: 1.0


    Examples
    --------
    >>> import numpy as np
    >>> from sklearn.datasets import make_classification
    >>> from sklearn.model_selection import train_test_split
    >>> from sklearn.naive_bayes import GaussianNB
    >>> X, y = make_classification(n_samples=1000, n_classes=2, n_informative=10)
    >>> X_train, X_test, y_train, y_test = train_test_split(X, y)
    >>> X_train_proper, X_cal, y_train_proper, y_cal = train_test_split(X_train, y_train, test_size=0.2, shuffle=False)
    >>> clf = GaussianNB()
    >>> clf.fit(X_train_proper, y_train_proper)
    >>> p_cal = clf.predict_proba(X_cal)
    >>> p_test = clf.predict_proba(X_test)
    >>> va = VennAbers()
    >>> va.fit(p_cal, y_cal)
    >>> p_prime, p0_p1 = va.predict_proba(p_test)
    """

    def __init__(self):
        self.p0 = None
        self.p1 = None
        self.c = None

    def fit(self, p_cal, y_cal, precision=None):
        """Fits the VennAbers calibrator to the calibration dataset


        Parameters
        ----------
        p_cal : {array-like}, shape (n_samples,)
            Input data for calibration consisting of calibration set probabilities

        y_cal : {array-like}, shape (n_samples,)
            Associated binary class labels.

        precision: int, default = None
            Optional number of decimal points to which Venn-Abers calibration probabilities p_cal are rounded to.
            Yields significantly faster computation time for larger calibration datasets
        """
        self.p0, self.p1, self.c = calc_p0p1(p_cal, y_cal, precision)

    def predict_proba(self, p_test):
        """Generates Venn-Abers probability estimates


        Parameters
        ----------
        p_test : {array-like}, shape (n_samples, 2)
            An array of probability outputs which are to be calibrated


        Returns
        ----------
        p_prime : {array-like}, shape (n_samples, 2)
            Calibrated probability outputs

        p0_p1 : {array-like}, shape (n_samples, 2)
            Associated multiprobability outputs
            (as described in Section 4 in https://arxiv.org/pdf/1511.00213.pdf)
        """
        p_prime, p0_p1 = calc_probs(self.p0, self.p1, self.c, p_test)
        return p_prime, p0_p1


def calc_p0p1(p_cal, y_cal, precision=None):
    """Function that calculates isotonic calibration vectors required for Venn-ABERS calibration

    This function relies on the geometric representation of isotonic
    regression as the slope of the GCM (greatest convex minorant) of the CSD
    (cumulative sum diagram) as decribed in [1] pages 9–13 (especially Theorem 1.1).
    In particular, the function implements algorithms 1-4 as described in Chapter 2 in [2]


    References
    ----------
    [1] Richard E. Barlow, D. J. Bartholomew, J. M. Bremner, and H. Daniel
    Brunk. Statistical Inference under Order Restrictions: The Theory and
    Application of Isotonic Regression. Wiley, London, 1972.

    [2] Vovk, Vladimir, Ivan Petej, and Valentina Fedorova. "Large-scale probabilistic predictors
    with and without guarantees of validity."Advances in Neural Information Processing Systems 28 (2015).
    (arxiv version https://arxiv.org/pdf/1511.00213.pdf)


    Parameters
    ----------
    p_cal : {array-like}, shape (n_samples,)
    Input data for calibration consisting of calibration set probabilities

    y_cal : {array-like}, shape (n_samples,)
    Associated binary class labels.

    precision: int, default = None
    Optional number of decimal points to which Venn-Abers calibration probabilities p_cal are rounded to.
    Yields significantly faster computation time for larger calibration datasets.
    If None no rounding is applied.


    Returns
    ----------
    p_0 : {array-like}, shape (n_samples, )
        Precomputed vector storing values of the isotonic regression fitted to a sequence
        that contains binary class label 0

    p_1 : {array-like}, shape (n_samples, )
        Precomputed vector storing values of the isotonic regression fitted to a sequence
        that contains binary class label 1

    c : {array-like}, shape (n_samples, )
        Ordered set of unique calibration probabilities
    """
    if precision is not None:
        cal = np.hstack(
            (np.round(p_cal[:, 1], precision).reshape(-1, 1), y_cal.reshape(-1, 1))
        )
    else:
        cal = np.hstack((p_cal[:, 1].reshape(-1, 1), y_cal.reshape(-1, 1)))
    ix = np.argsort(cal[:, 0])
    k_sort = cal[ix, 0]
    k_label_sort = cal[ix, 1]

    c = np.unique(k_sort)
    ia = np.searchsorted(k_sort, c)

    w = np.zeros(len(c))

    w[:-1] = np.diff(ia)
    w[-1] = len(k_sort) - ia[-1]

    k_dash = len(c)
    P = np.zeros((k_dash + 2, 2))

    P[0, :] = -1

    P[2:, 0] = np.cumsum(w)
    P[2:-1, 1] = np.cumsum(k_label_sort)[(ia - 1)[1:]]
    P[-1, 1] = np.cumsum(k_label_sort)[-1]

    p1 = np.zeros((len(c) + 1, 2))
    p1[1:, 0] = c

    P1 = P[1:] + 1

    for i in range(len(p1)):

        P1[i, :] = P1[i, :] - 1

        if i == 0:
            grads = np.divide(P1[:, 1], P1[:, 0])
            grad = np.nanmin(grads)
            p1[i, 1] = grad
            c_point = 0
        else:
            imp_point = P1[c_point, 1] + (P1[i, 0] - P1[c_point, 0]) * grad

            if P1[i, 1] < imp_point:
                grads = np.divide((P1[i:, 1] - P1[i, 1]), (P1[i:, 0] - P1[i, 0]))
                if np.sum(np.isnan(np.nanmin(grads))) == 0:
                    grad = np.nanmin(grads)
                c_point = i
                p1[i, 1] = grad
            else:
                p1[i, 1] = grad

    p0 = np.zeros((len(c) + 1, 2))
    p0[1:, 0] = c

    P0 = P[1:]

    for i in range(len(p1) - 1, -1, -1):
        P0[i, 0] = P0[i, 0] + 1

        if i == len(p1) - 1:
            grads = np.divide((P0[:, 1] - P0[i, 1]), (P0[:, 0] - P0[i, 0]))
            grad = np.nanmax(grads)
            p0[i, 1] = grad
            c_point = i
        else:
            imp_point = P0[c_point, 1] + (P0[i, 0] - P0[c_point, 0]) * grad

            if P0[i, 1] < imp_point:
                grads = np.divide((P0[:, 1] - P0[i, 1]), (P0[:, 0] - P0[i, 0]))
                grads[i:] = 0
                grad = np.nanmax(grads)
                c_point = i
                p0[i, 1] = grad
            else:
                p0[i, 1] = grad
    return p0, p1, c


def calc_probs(p0, p1, c, p_test):
    """Function that calculates Venn-Abers multiprobability outputs and associated calibrated probabilities



    In particular, the function implements algorithms 5-6 as described in Chapter 2 in [1]


    References
    ----------
    [1] Vovk, Vladimir, Ivan Petej, and Valentina Fedorova. "Large-scale probabilistic predictors
    with and without guarantees of validity."Advances in Neural Information Processing Systems 28 (2015).
    (arxiv version https://arxiv.org/pdf/1511.00213.pdf)


    Parameters
    ----------
    p0 : {array-like}, shape (n_samples, )
        Precomputed vector storing values of the isotonic regression fitted to a sequence
        that contains binary class label 0

    p1 : {array-like}, shape (n_samples, )
        Precomputed vector storing values of the isotonic regression fitted to a sequence
        that contains binary class label 1

    c : {array-like}, shape (n_samples, )
        Ordered set of unique calibration probabilities

    p_test : {array-like}, shape (n_samples, 2)
        An array of probability outputs which are to be calibrated


    Returns
    ----------
    p_prime : {array-like}, shape (n_samples, 2)
    Calibrated probability outputs

    p0_p1 : {array-like}, shape (n_samples, 2)
    Associated multiprobability outputs
    (as described in Section 4 in https://arxiv.org/pdf/1511.00213.pdf)
    """
    out = p_test[:, 1]
    p0_p1 = np.hstack(
        (
            p0[np.searchsorted(c, out, "right"), 1].reshape(-1, 1),
            p1[np.searchsorted(c, out, "left"), 1].reshape(-1, 1),
        )
    )

    p_prime = np.zeros((len(out), 2))
    p_prime[:, 1] = p0_p1[:, 1] / (1 - p0_p1[:, 0] + p0_p1[:, 1])
    p_prime[:, 0] = 1 - p_prime[:, 1]

    return p_prime, p0_p1


def geo_mean(a):
    return a.prod(axis=1) ** (1.0 / a.shape[1])
