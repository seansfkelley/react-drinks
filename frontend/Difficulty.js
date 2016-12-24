const _ = require('lodash');

const Difficulty = {
  EASY   : 'easy',
  MEDIUM : 'medium',
  HARD   : 'hard'
};

const ORDERED_DIFFICULTIES = [ Difficulty.EASY, Difficulty.MEDIUM, Difficulty.HARD ];

const HUMAN_READABLE = {
  [Difficulty.EASY]   : 'Easy',
  [Difficulty.MEDIUM] : 'Medium',
  [Difficulty.HARD]   : 'Hard'
};

const CLASS_NAME = {
  [Difficulty.EASY]   : 'easy',
  [Difficulty.MEDIUM] : 'medium',
  [Difficulty.HARD]   : 'hard'
};

const getHardest = function(difficulties) {
  if (!difficulties || !difficulties.length) {
    return Difficulty.EASY;
  } else {
    return _.max(difficulties, d => _.indexOf(ORDERED_DIFFICULTIES, d));
  }
};

const getEasiest = function(difficulties) {
  if (!difficulties || !difficulties.length) {
    return Difficulty.EASY;
  } else {
    return _.min(difficulties, d => _.indexOf(ORDERED_DIFFICULTIES, d));
  }
};

module.exports = _.extend(Difficulty, { getHardest, getEasiest, HUMAN_READABLE, CLASS_NAME });
