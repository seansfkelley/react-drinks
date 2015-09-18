Difficulty = {
  EASY   : 'easy'
  MEDIUM : 'medium'
  HARD   : 'hard'
}

ORDERED_DIFFICULTIES = [ Difficulty.EASY, Difficulty.MEDIUM, Difficulty.HARD ]

HUMAN_READABLE = {
  "#{Difficulty.EASY}"   : 'Easy'
  "#{Difficulty.MEDIUM}" : 'Medium'
  "#{Difficulty.HARD}"   : 'Hard'
}

CLASS_NAME = {
  "#{Difficulty.EASY}"   : 'easy'
  "#{Difficulty.MEDIUM}" : 'medium'
  "#{Difficulty.HARD}"   : 'hard'
}

getHardest = (difficulties) ->
  if not difficulties or not difficulties.length
    return Difficulty.EASY
  else
    return _.max difficulties, (d) -> _.indexOf ORDERED_DIFFICULTIES, d

getEasiest = (difficulties) ->
  if not difficulties or not difficulties.length
    return Difficulty.EASY
  else
    return _.min difficulties, (d) -> _.indexOf ORDERED_DIFFICULTIES, d

module.exports = _.extend Difficulty, { getHardest, getEasiest, HUMAN_READABLE, CLASS_NAME }
