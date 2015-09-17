Difficulty = {
  EASY   : 'easy'
  MEDIUM : 'medium'
  HARD   : 'hard'
}

ORDERED_DIFFICULTIES = [ Difficulty.EASY, Difficulty.MEDIUM, Difficulty.HARD ]

getHardest = (difficulties) ->
  if not difficulties or not difficulties.length
    return Difficulty.EASY
  else
    return _.max difficulties, (d) -> _.indexOf ORDERED_DIFFICULTIES, d

module.exports = _.extend Difficulty, { getHardest }
