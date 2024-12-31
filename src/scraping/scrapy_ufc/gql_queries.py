# standard library imports

# third party imports

# local imports


EVENTS_RECENT_QUERY = """
query EventsPromotionRecentQuery(
  $promotionSlug: String
  $dateLt: Date
  $dateGte: Date
  $after: String
  $first: Int
  $orderBy: String
) {
  promotion: promotionBySlug(slug: $promotionSlug) {
    ...EventsPromotionTabPanel_promotion_34GGrn
    id
  }
}

fragment EventCardList_events on EventNodeConnection {
  edges {
    node {
      id
      ...EventCard_event
    }
  }
}

fragment EventCard_event on EventNode {
  id
  name
  pk
  slug
  date
  venue
  city
  promotion {
    slug
    shortName
    id
  }
  ...EventPoster_event
}

fragment EventPoster_event on EventNode {
  name
  poster
  posterWide
  promotion {
    shortName
    logo
    id
  }
}

fragment EventsPromotionTabPanel_promotion_34GGrn on PromotionNode {
  ...PromotionEventCardListInfiniteScroll_promotion_34GGrn
}

fragment PromotionEventCardListInfiniteScroll_promotion_34GGrn on PromotionNode {
  events(first: $first, after: $after, date_Gte: $dateGte, date_Lt: $dateLt, orderBy: $orderBy) {
    ...EventCardList_events
    edges {
      node {
        id
        __typename
      }
      cursor
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
"""

EVENT_QUERY = """
query EventQuery(
  $eventPk: Int
) {
  event: eventByPk(pk: $eventPk) {
    pk
    slug
    ...EventTabPanelInfo_event
    id
  }
}

fragment EventPoster_event on EventNode {
  name
  poster
  posterWide
  promotion {
    shortName
    logo
    id
  }
}

fragment EventTabPanelInfo_event on EventNode {
  date
  venue
  city
  broadcast
  poster
  promotion {
    shortName
    slug
    id
  }
  ...EventPoster_event
}
"""

EVENT_FIGHTS_QUERY = """
query EventFightsQuery(
  $eventPk: Int
) {
  event: eventByPk(pk: $eventPk) {
    pk
    slug
    fights {
      ...EventTabPanelFights_fights
    }
    id
  }
}

fragment EventTabPanelFights_fights on FightNodeConnection {
  edges {
    node {
      id
    }
  }
  ...FightTable_fights
  ...FightCardList_fights
}

fragment FightCardList_fights on FightNodeConnection {
  edges {
    node {
      ...FightCard_fight
      id
    }
  }
}

fragment FightCard_fight on FightNode {
  id
  pk
  fighter1 {
    id
    firstName
    lastName
    slug
  }
  fighter2 {
    id
    firstName
    lastName
    slug
  }
  fighterWinner {
    id
  }
  order
  weightClass {
    weightClass
    weight
    id
  }
  fighter1Odds
  fighter2Odds
  fightType
  methodOfVictory1
  methodOfVictory2
  round
  duration
  slug
}

fragment FightTable_fights on FightNodeConnection {
  edges {
    node {
      id
      fighter1 {
        id
        firstName
        lastName
        slug
        ...FighterFlag_fighter
      }
      fighter2 {
        id
        firstName
        lastName
        slug
        ...FighterFlag_fighter
      }
      fighterWinner {
        id
        firstName
        lastName
        slug
        ...FighterFlag_fighter
      }
      order
      weightClass {
        weightClass
        weight
        id
      }
      isCancelled
      fightType
      methodOfVictory1
      methodOfVictory2
      round
      duration
      slug
    }
  }
}

fragment FighterFlag_fighter on FighterNode {
  nationality
}
"""

FIGHTER_QUERY = """
query FighterQuery(
  $fighterSlug: String
) {
  fighter: fighterBySlug(slug: $fighterSlug) {
    ...FighterTabPanelInfo_fighter
    id
  }
}

fragment FighterTabPanelInfo_fighter on FighterNode {
  ...FighterTableInfo_fighter
  ...FighterTableFightingStyle_fighter
}

fragment FighterTableFightingStyle_fighter on FighterNode {
  stance
}

fragment FighterTableInfo_fighter on FighterNode {
  id
  pk
  slug
  firstName
  lastName
  nickName
  birthDate
  nationality
  height
  reach
  legReach
  fightingStyle
}
"""

FIGHT_ODDS_QUERY = """
query FightOddsQuery(
  $fightSlug: String
) {
  sportsbooks: allSportsbooks(hasOdds: true) {
    ...FightTabPanelOdds_sportsbooks
  }
  fightOfferTable(slug: $fightSlug) {
    ...FightTabPanelOdds_fightOfferTable
    id
  }
  outcomes: fightOutcomesTable(slug: $fightSlug) {
    ...FightTabPanelOdds_outcomes
  }
  fight: fightBySlug(slug: $fightSlug) {
    ...FightTabPanelOdds_fight
    id
  }
}

fragment FightExpectedOutcomesTable_fight on FightNode {
  fighter1 {
    pk
    lastName
    id
  }
  fighter2 {
    pk
    lastName
    id
  }
}

fragment FightExpectedOutcomesTable_outcomes on FightOutcomeNodeConnection {
  edges {
    node {
      offerTypeId
      isNot
      avgOdds
      fighterPk
      description
      notDescription
    }
  }
}

fragment FightOfferTable_fightOfferTable on FightOfferTableNode {
  slug
  fighter1 {
    firstName
    lastName
    id
  }
  fighter2 {
    firstName
    lastName
    id
  }
  bestOdds1
  bestOdds2
  straightOffers {
    edges {
      node {
        sportsbook {
          id
          shortName
          slug
        }
        outcome1 {
          id
          odds
          oddsOpen
          oddsBest
          oddsWorst
          ...OddsWithArrowButton_outcome
        }
        outcome2 {
          id
          odds
          oddsOpen
          oddsBest
          oddsWorst
          ...OddsWithArrowButton_outcome
        }
        id
      }
    }
  }
}

fragment FightOfferTable_sportsbooks on SportsbookNodeConnection {
  edges {
    node {
      id
      shortName
      slug
    }
  }
}

fragment FightTabPanelOdds_fight on FightNode {
  ...FightExpectedOutcomesTable_fight
}

fragment FightTabPanelOdds_fightOfferTable on FightOfferTableNode {
  ...FightOfferTable_fightOfferTable
  propCount
  slug
}

fragment FightTabPanelOdds_outcomes on FightOutcomeNodeConnection {
  ...FightExpectedOutcomesTable_outcomes
}

fragment FightTabPanelOdds_sportsbooks on SportsbookNodeConnection {
  ...FightOfferTable_sportsbooks
}

fragment OddsWithArrowButton_outcome on OutcomeNode {
  id
  ...OddsWithArrow_outcome
}

fragment OddsWithArrow_outcome on OutcomeNode {
  odds
  oddsPrev
}
"""

FIGHT_PROP_OFFERS_TABLE_QUERY = """
query FightPropOfferTableQrQuery(
  $fightSlug: String!
) {
  sportsbooks: allSportsbooks(hasOdds: true) {
    ...FightPropOfferTable_sportsbooks
  }
  fightPropOfferTable(slug: $fightSlug) {
    ...FightPropOfferTable_fightPropOfferTable
    id
  }
  offerTypes: allOfferTypes {
    ...FightPropOfferTable_offerTypes
  }
}

fragment FightPropOfferTable_fightPropOfferTable on FightPropOfferTableNode {
  propOffers {
    edges {
      node {
        propName1
        propName2
        bestOdds1
        bestOdds2
        offerType {
          id
        }
        offers {
          edges {
            node {
              sportsbook {
                id
              }
              outcome1 {
                id
                odds
                ...OddsWithArrowButton_outcome
              }
              outcome2 {
                id
                odds
                ...OddsWithArrowButton_outcome
              }
              id
            }
          }
        }
      }
    }
  }
}

fragment FightPropOfferTable_offerTypes on OfferTypeNodeConnection {
  edges {
    node {
      id
    }
  }
}

fragment FightPropOfferTable_sportsbooks on SportsbookNodeConnection {
  edges {
    node {
      id
      shortName
      slug
    }
  }
}

fragment OddsWithArrowButton_outcome on OutcomeNode {
  id
  ...OddsWithArrow_outcome
}

fragment OddsWithArrow_outcome on OutcomeNode {
  odds
  oddsPrev
}
"""

POPOVER_ODDS_CHART_QUERY = """
query PopoverOddsChartQuery(
  $outcomeId: ID!
) {
  odds: allOdds(outcome: $outcomeId, orderBy: "timestamp") {
    ...OddsChart_odds
    edges {
      node {
        timestamp
        id
      }
    }
  }
  outcome(id: $outcomeId) {
    ...OutcomeName_outcome
    ...AddBetForm_outcome
    ...DialogAddBet_outcome
    ...ButtonAddParlay_outcome
    offer {
      sportsbook {
        fullName
        slug
        shortName
        websiteUrl
        id
      }
      timestamp
      id
    }
    id
  }
}

fragment AddBetForm_outcome on OutcomeNode {
  ...OutcomeName_outcome
  id
  odds
  fighter {
    id
  }
  offer {
    fight {
      fighter1 {
        id
        lastName
      }
      fighter2 {
        id
        lastName
      }
      id
    }
    id
  }
}

fragment ButtonAddParlay_outcome on OutcomeNode {
  ...OutcomeName_outcome
  id
  odds
  isNot
  fighter {
    firstName
    lastName
    id
  }
  offer {
    offerType {
      offerTypeId
      description
      value
      id
    }
    fight {
      id
      fighter1 {
        lastName
        id
      }
      fighter2 {
        lastName
        id
      }
    }
    sportsbook {
      id
    }
    id
  }
}

fragment DialogAddBet_outcome on OutcomeNode {
  ...OutcomeName_outcome
  id
  odds
  isNot
  fighter {
    firstName
    lastName
    id
  }
  offer {
    offerType {
      offerTypeId
      description
      value
      id
    }
    sportsbook {
      fullName
      id
    }
    id
  }
}

fragment OddsChart_odds on OddsNodeConnection {
  edges {
    node {
      odds
      timestamp
      id
    }
  }
}

fragment OutcomeName_outcome on OutcomeNode {
  odds
  isNot
  fighter {
    firstName
    lastName
    id
  }
  offer {
    offerType {
      notDescription
      offerTypeId
      description
      value
      id
    }
    id
  }
}
"""
