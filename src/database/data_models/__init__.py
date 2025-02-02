from ._association_tables import BoutAssociation, EventAssociation, FighterAssociation
from .base import Base
from .bestfightodds import (
    BestFightOddsBoutPropositionOdds,
    BestFightOddsEventPropositionOdds,
    BestFightOddsEvents,
    BestFightOddsFighters,
    BestFightOddsMoneylineOdds,
)
from .betmma import (
    BetMMABouts,
    BetMMAEvents,
    BetMMAFighterHistories,
    BetMMAFighters,
    BetMMALateReplacements,
    BetMMAMissedWeights,
)
from .espn import (
    ESPNBouts,
    ESPNBoutStats,
    ESPNEvents,
    ESPNFighterHistories,
    ESPNFighters,
    ESPNTeams,
    ESPNVenues,
)
from .fightmatrix import (
    FightMatrixBouts,
    FightMatrixEvents,
    FightMatrixFighterHistories,
    FightMatrixFighters,
    FightMatrixRankings,
)
from .fightoddsio import (
    FightOddsIOBouts,
    FightOddsIOEvents,
    FightOddsIOFighters,
    FightOddsIOMoneylineOdds,
    FightOddsIOSportsbooks,
)
from .mmadecisions import (
    MMADecisionsBouts,
    MMADecisionsDeductions,
    MMADecisionsEvents,
    MMADecisionsFighters,
    MMADecisionsJudges,
    MMADecisionsJudgeScores,
    MMADecisionsMediaScores,
)
from .sherdog import (
    SherdogBouts,
    SherdogEvents,
    SherdogFighterHistories,
    SherdogFighters,
)
from .tapology import (
    TapologyBouts,
    TapologyCommunityPicks,
    TapologyEvents,
    TapologyFighterGyms,
    TapologyFighterHistories,
    TapologyFighters,
    TapologyGyms,
    TapologyRehydrationWeights,
)
from .ufcstats import (
    UFCStatsBouts,
    UFCStatsEvents,
    UFCStatsFighterHistories,
    UFCStatsFighters,
    UFCStatsRoundStats,
)
from .wikipedia import WikipediaEvents, WikipediaVenues
