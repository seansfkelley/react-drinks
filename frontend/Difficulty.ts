import { minBy, maxBy } from 'lodash';

// TODO: Fat enums would be cool, but I don't want to deal with the required refactoring to enable them
// right now (specifically, ).
// export type Difficulty = string & { __difficultyBrand: any, display: string, className: string };
// export const Difficulty = {
//   EASY: assign(new String('easy'), { display: 'Easy', className: 'easy' }),
//   MEDIUM: assign(new String('medium'), { display: 'Medium', className: 'medium' }),
//   HARD: assign(new String('hard'), { display: 'Hard', className: 'hard' }),
// };

export type Difficulty = ('easy' | 'medium' | 'hard') & { __difficultyBrand: any };
export const Difficulty = {
  EASY: 'easy' as Difficulty,
  MEDIUM: 'medium' as Difficulty,
  HARD: 'hard' as Difficulty
};

export const HUMAN_READABLE = {
  [Difficulty.EASY]: 'Easy',
  [Difficulty.MEDIUM]: 'Medium',
  [Difficulty.HARD]: 'Hard'
};

export const CLASS_NAME = {
  [Difficulty.EASY]: 'easy',
  [Difficulty.MEDIUM]: 'medium',
  [Difficulty.HARD]: 'hard'
};

const ORDERED_DIFFICULTIES = [Difficulty.EASY, Difficulty.MEDIUM, Difficulty.HARD];

export function getHardest(difficulties: (string | Difficulty)[]) {
  if (!difficulties || !difficulties.length) {
    return Difficulty.EASY;
  } else {
    return maxBy(difficulties, d => ORDERED_DIFFICULTIES.indexOf(d as Difficulty)) as Difficulty;
  }
};

export function getEasiest(difficulties: (string | Difficulty)[]) {
  if (!difficulties || !difficulties.length) {
    return Difficulty.EASY;
  } else {
    return minBy(difficulties, d => ORDERED_DIFFICULTIES.indexOf(d as Difficulty)) as Difficulty;
  }
};
