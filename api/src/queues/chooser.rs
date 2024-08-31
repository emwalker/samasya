use crate::types::{ApiError, Result, Timestamp};
use chrono::{DateTime, TimeDelta, Utc};
use itertools::Itertools;

#[allow(dead_code)]
#[derive(Debug)]
enum AnswerState {
    Unseen,
    Unsure,
    Correct,
    Incorrect,
}
use AnswerState::*;

#[allow(dead_code)]
#[derive(Debug)]
enum NextProblem {
    EmptyQueue,

    NotReady {
        available_at: Timestamp,
    },

    Ready {
        available_at: Timestamp,
        problem_id: String,
    },
}

#[allow(dead_code)]
#[derive(Debug)]
struct AnswerData {
    consecutive_correct: u32,
    answered_at: Timestamp,
    state: AnswerState,
}

#[allow(dead_code)]
#[derive(Debug)]
struct AnsweredProblem {
    problem_id: String,
    data: Option<AnswerData>,
}

#[allow(dead_code)]
#[derive(Clone, Copy, Debug)]
enum TimeUnit {
    Minutes,
    Hours,
}
use TimeUnit::*;

#[allow(dead_code)]
#[derive(Debug)]
struct Clock {
    now: Timestamp,
    unit: TimeUnit,
}

impl Clock {
    #[allow(dead_code)]
    fn new(unit: TimeUnit) -> Self {
        Self {
            now: Timestamp::from_timestamp(0).unwrap(),
            unit,
        }
    }

    #[allow(dead_code)]
    fn ticks(&self, n: i32) -> Option<Self> {
        let ticks = self.one_tick().checked_mul(n)?;
        let now = self.now.checked_add_signed(ticks)?;

        Some(Self {
            now,
            unit: self.unit,
        })
    }

    #[allow(dead_code)]
    fn one_tick(&self) -> TimeDelta {
        match self.unit {
            Minutes => TimeDelta::minutes(1),
            Hours => TimeDelta::hours(1),
        }
    }
}

#[allow(dead_code)]
struct SpacedRepetitionV1;

#[allow(dead_code)]
trait Choose {
    fn choose(&self, clock: Clock, history: &[AnsweredProblem]) -> Result<NextProblem>;
}

impl Choose for SpacedRepetitionV1 {
    fn choose(&self, clock: Clock, history: &[AnsweredProblem]) -> Result<NextProblem> {
        if history.is_empty() {
            return Ok(NextProblem::EmptyQueue);
        }

        let (problem_id, next_available_at) = self.next_problem(clock, history)?;

        if let Some(problem_id) = problem_id {
            return Ok(NextProblem::Ready {
                problem_id,
                available_at: next_available_at,
            });
        }

        Ok(NextProblem::NotReady {
            available_at: next_available_at,
        })
    }
}

impl SpacedRepetitionV1 {
    #[allow(dead_code)]
    fn next_problem(
        &self,
        clock: Clock,
        history: &[AnsweredProblem],
    ) -> Result<(Option<String>, Timestamp)> {
        // Select the most recent answers for each problem in the available history, then sort
        // by oldest to newest.
        let sorted = history
            .iter()
            .filter_map(|row| row.data.as_ref().map(|data| (&row.problem_id, data)))
            .sorted_by_key(|(_, data)| &data.answered_at)
            .rev()
            .unique_by(|&(problem_id, _)| problem_id)
            .sorted_by_key(|(_, data)| &data.answered_at);

        let mut next_available_at: Timestamp = DateTime::<Utc>::MAX_UTC.into();

        for (problem_id, data) in sorted {
            let AnswerData {
                consecutive_correct,
                state,
                answered_at,
            } = data;

            let n = match state {
                Unsure => 90,
                _ => 2i32.pow(*consecutive_correct),
            };
            debug_assert!(n > 0, "expected 1 or more ticks");

            let delta = clock
                .one_tick()
                .checked_mul(n)
                .ok_or_else(|| ApiError::General(format!("invalid duration: {n} ticks")))?;

            let available_at = answered_at
                .checked_add_signed(delta)
                .ok_or_else(|| ApiError::General(String::from("date shift failed")))?;

            if available_at <= clock.now {
                return Ok((Some(problem_id.into()), available_at));
            }
            next_available_at = next_available_at.min(available_at);
        }

        if let Some(row) = history.iter().find(|row| row.data.is_none()) {
            return Ok((Some(row.problem_id.clone()), clock.now));
        }

        Ok((None, next_available_at))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn c(
        problem_id: &str,
        consecutive_correct: u32,
        answered_at: Option<Clock>,
        state: AnswerState,
    ) -> AnsweredProblem {
        AnsweredProblem {
            problem_id: problem_id.into(),
            data: Some(AnswerData {
                consecutive_correct,
                answered_at: answered_at.unwrap().now,
                state,
            }),
        }
    }

    fn spaced_repetition() -> (SpacedRepetitionV1, Clock) {
        (SpacedRepetitionV1, Clock::new(Minutes))
    }

    fn time_eq(timestamp: Timestamp, clock: Option<Clock>) -> bool {
        timestamp == clock.unwrap().now
    }

    #[test]
    fn simple_case() {
        let (chooser, clock) = spaced_repetition();
        let history = vec![
            c("0", 0, clock.ticks(1), Unseen),
            c("1", 2, clock.ticks(-1), Correct),
            c("2", 0, clock.ticks(-2), Incorrect),
        ];
        let next = chooser.choose(clock.ticks(-1).unwrap(), &history).unwrap();

        let NextProblem::Ready {
            problem_id,
            available_at,
        } = next
        else {
            panic!()
        };
        assert_eq!(problem_id, "2");
        assert!(time_eq(available_at, clock.ticks(-1)));
    }

    #[test]
    fn empty_queue() {
        let (chooser, clock) = spaced_repetition();
        let history = vec![];
        let next = chooser.choose(clock.ticks(-1).unwrap(), &history).unwrap();

        assert!(matches!(next, NextProblem::EmptyQueue));
    }

    #[test]
    fn several_available_problems() {
        let (chooser, clock) = spaced_repetition();
        let history = vec![
            c("0", 1, clock.ticks(-1), Correct),
            c("1", 2, clock.ticks(-3), Correct),
            c("2", 3, clock.ticks(-10), Correct),
        ];

        let next = chooser.choose(clock.ticks(-2).unwrap(), &history).unwrap();
        let NextProblem::Ready {
            problem_id,
            available_at,
        } = next
        else {
            panic!()
        };
        assert_eq!(problem_id, "2");
        assert!(time_eq(available_at, clock.ticks(-2)));
    }

    #[test]
    fn more_than_one_choice() {
        let (chooser, clock) = spaced_repetition();
        let history = vec![
            c("0", 1, clock.ticks(0), Correct),
            c("0", 0, clock.ticks(-1), Incorrect),
            c("0", 0, clock.ticks(-2), Incorrect),
        ];
        let next = chooser.choose(clock.ticks(1).unwrap(), &history).unwrap();

        let NextProblem::NotReady { available_at } = next else {
            panic!()
        };
        assert!(time_eq(available_at, clock.ticks(2)));
    }

    #[test]
    fn no_ready_questions_1() {
        let (chooser, clock) = spaced_repetition();
        let history = vec![
            c("0", 1, clock.ticks(0), Correct),
            c("1", 2, clock.ticks(0), Correct),
            c("2", 3, clock.ticks(0), Correct),
        ];
        let next = chooser.choose(clock.ticks(1).unwrap(), &history).unwrap();

        let NextProblem::NotReady { available_at } = next else {
            panic!()
        };
        assert!(time_eq(available_at, clock.ticks(2)));
    }

    #[test]
    fn no_ready_questions_2() {
        let (chooser, clock) = spaced_repetition();
        let history = vec![
            c("0", 1, clock.ticks(0), Correct),
            c("1", 1, clock.ticks(-1), Correct),
            c("2", 4, clock.ticks(-1), Correct),
        ];
        let next = chooser.choose(clock.ticks(0).unwrap(), &history).unwrap();

        let NextProblem::NotReady { available_at } = next else {
            panic!()
        };
        assert!(time_eq(available_at, clock.ticks(1)));
    }

    #[test]
    fn no_ready_questions_3() {
        let (chooser, clock) = spaced_repetition();
        let history = vec![c("0", 2, clock.ticks(0), Correct)];
        let next = chooser.choose(clock.ticks(3).unwrap(), &history).unwrap();

        let NextProblem::NotReady { available_at } = next else {
            panic!()
        };
        assert!(time_eq(available_at, clock.ticks(4)));
    }

    #[test]
    fn unsolved_problems() {
        let (chooser, clock) = spaced_repetition();
        let history = vec![
            AnsweredProblem {
                problem_id: String::from("0"),
                data: None,
            },
            AnsweredProblem {
                problem_id: String::from("1"),
                data: None,
            },
        ];
        let next = chooser.choose(clock.ticks(0).unwrap(), &history).unwrap();

        let NextProblem::Ready {
            problem_id,
            available_at,
        } = next
        else {
            panic!()
        };
        assert_eq!(problem_id, "0");
        assert!(time_eq(available_at, clock.ticks(0)));
    }

    #[test]
    fn hard_problems() {
        let (chooser, clock) = spaced_repetition();
        let history = vec![
            c("0", 0, clock.ticks(0), Unsure),
            c("1", 0, clock.ticks(-1), Unsure),
            c("2", 0, clock.ticks(-2), Unsure),
        ];
        let next = chooser.choose(clock.ticks(0).unwrap(), &history).unwrap();

        let NextProblem::NotReady { available_at } = next else {
            panic!()
        };
        assert!(time_eq(available_at, clock.ticks(88)));
    }

    #[test]
    fn next_available_time() {
        // The next available time is not taken from the first unanswered question
        let (chooser, clock) = spaced_repetition();
        let history = vec![
            c("0", 0, clock.ticks(-2), Unsure),
            c("1", 1, clock.ticks(-1), Correct),
            c("2", 0, clock.ticks(0), Incorrect),
            c("3", 1, clock.ticks(1), Correct),
        ];
        let next = chooser.choose(clock.ticks(0).unwrap(), &history).unwrap();

        let NextProblem::NotReady { available_at } = next else {
            panic!()
        };
        assert!(time_eq(available_at, clock.ticks(1)));
    }
}
