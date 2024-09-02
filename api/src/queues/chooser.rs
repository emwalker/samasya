use super::{Clock, NextProblem, Outcome};
use crate::{
    queues::OutcomeData,
    types::{QueueStrategy, Result, Timestamp},
};
use chrono::{DateTime, Utc};
use itertools::Itertools;

pub(crate) struct SpacedRepetitionV1;

pub(crate) trait Choose {
    fn choose(&self, clock: Clock, history: &[Outcome]) -> Result<NextProblem>;
}

impl Choose for QueueStrategy {
    fn choose(&self, clock: Clock, history: &[Outcome]) -> Result<NextProblem> {
        match self {
            Self::SpacedRepetitionV1 => SpacedRepetitionV1.choose(clock, history),
            _ => unimplemented!(),
        }
    }
}

impl Choose for SpacedRepetitionV1 {
    fn choose(&self, clock: Clock, history: &[Outcome]) -> Result<NextProblem> {
        if history.is_empty() {
            return Ok(NextProblem::EmptyQueue);
        }

        let (approach_id, next_available_at) = self.next_problem(clock, history)?;

        if let Some(approach_id) = approach_id {
            return Ok(NextProblem::Ready {
                approach_id,
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
        history: &[Outcome],
    ) -> Result<(Option<String>, Timestamp)> {
        let sorted = self.sort_history(history);
        let mut next_available_at: Timestamp = DateTime::<Utc>::MAX_UTC.into();

        for (approach_id, data) in sorted {
            let OutcomeData {
                progress,
                state,
                added_at,
                ..
            } = data;

            let available_at = state.next_available_at(&clock, added_at, *progress)?;

            if available_at <= clock.now {
                return Ok((Some(approach_id.clone()), available_at));
            }
            next_available_at = next_available_at.min(available_at);
        }

        if let Some(row) = history.iter().find(|row| row.data.is_none()) {
            return Ok((Some(row.approach_id.clone()), clock.now));
        }

        Ok((None, next_available_at))
    }

    fn sort_history<'h>(
        &'h self,
        history: &'h [Outcome],
    ) -> impl Iterator<Item = (&String, &OutcomeData)> + '_ {
        // Select the most recent answers for each problem in the available history, then sort
        // by oldest to newest.
        history
            .iter()
            .filter_map(|row| row.data.as_ref().map(|data| (&row.approach_id, data)))
            .sorted_by_key(|(_, data)| &data.added_at)
            .rev()
            .unique_by(|&(approach_id, _)| approach_id)
            .sorted_by_key(|(_, data)| &data.added_at)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::queues::{
        Cadence,
        OutcomeType::{self, *},
    };

    fn a(
        approach_id: &str,
        consecutive_correct: u32,
        answered_at: Option<Clock>,
        state: OutcomeType,
    ) -> Outcome {
        Outcome {
            approach_id: approach_id.to_string(),
            data: Some(OutcomeData {
                progress: consecutive_correct,
                added_at: answered_at.unwrap().now,
                state,
            }),
        }
    }

    fn spaced_repetition() -> (SpacedRepetitionV1, Clock) {
        (SpacedRepetitionV1, Clock::new(Cadence::Minutes))
    }

    fn time_eq(timestamp: Timestamp, clock: Option<Clock>) -> bool {
        timestamp == clock.unwrap().now
    }

    #[test]
    fn simple_case() {
        let (chooser, clock) = spaced_repetition();
        let history = vec![
            a("0", 0, clock.ticks(1), NeedsRetry),
            a("1", 2, clock.ticks(-1), Completed),
            a("2", 0, clock.ticks(-2), NeedsRetry),
        ];
        let next = chooser.choose(clock.ticks(-1).unwrap(), &history).unwrap();

        let NextProblem::Ready {
            approach_id,
            available_at,
        } = next
        else {
            panic!()
        };
        assert_eq!(approach_id, "2");
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
            a("0", 1, clock.ticks(-1), Completed),
            a("1", 2, clock.ticks(-3), Completed),
            a("2", 3, clock.ticks(-10), Completed),
        ];

        let next = chooser.choose(clock.ticks(-2).unwrap(), &history).unwrap();
        let NextProblem::Ready {
            approach_id,
            available_at,
        } = next
        else {
            panic!()
        };
        assert_eq!(approach_id, "2");
        assert!(time_eq(available_at, clock.ticks(-2)));
    }

    #[test]
    fn more_than_one_choice() {
        let (chooser, clock) = spaced_repetition();
        let history = vec![
            a("0", 1, clock.ticks(0), Completed),
            a("0", 0, clock.ticks(-1), NeedsRetry),
            a("0", 0, clock.ticks(-2), NeedsRetry),
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
            a("0", 1, clock.ticks(0), Completed),
            a("1", 2, clock.ticks(0), Completed),
            a("2", 3, clock.ticks(0), Completed),
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
            a("0", 1, clock.ticks(0), Completed),
            a("1", 1, clock.ticks(-1), Completed),
            a("2", 4, clock.ticks(-1), Completed),
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
        let history = vec![a("0", 2, clock.ticks(0), Completed)];
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
            Outcome {
                approach_id: String::from("0"),
                data: None,
            },
            Outcome {
                approach_id: String::from("1"),
                data: None,
            },
        ];
        let next = chooser.choose(clock.ticks(0).unwrap(), &history).unwrap();

        let NextProblem::Ready {
            approach_id,
            available_at,
        } = next
        else {
            panic!()
        };
        assert_eq!(approach_id, "0");
        assert!(time_eq(available_at, clock.ticks(0)));
    }

    #[test]
    fn hard_problems() {
        let (chooser, clock) = spaced_repetition();
        let history = vec![
            a("0", 0, clock.ticks(0), TooHard),
            a("1", 0, clock.ticks(-1), TooHard),
            a("2", 0, clock.ticks(-2), TooHard),
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
            a("0", 0, clock.ticks(-2), TooHard),
            a("1", 1, clock.ticks(-1), Completed),
            a("2", 0, clock.ticks(0), NeedsRetry),
            a("3", 1, clock.ticks(1), Completed),
        ];
        let next = chooser.choose(clock.ticks(0).unwrap(), &history).unwrap();

        let NextProblem::NotReady { available_at } = next else {
            panic!()
        };
        assert!(time_eq(available_at, clock.ticks(1)));
    }
}
