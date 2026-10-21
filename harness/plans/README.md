# Plans

Write a plan when work spans more than one PR, changes a system's
shape, or needs agreed targets before building (an epic, a
rebalance, a migration). Single-PR features don't need one; their
`behavior` field is the spec.

- One file per plan: `harness/plans/<epic-or-feature-id>.md`, from
  `_TEMPLATE.md`.
- Discuss the plan with the user before building. Record the
  approval date in its `Status` line.
- Each phase maps to one `harness/feature_list.json` entry and one
  stacked PR (`harness/docs/STACKED_PRS.md`).
- Keep the plan honest as work proceeds: mark phases done, record
  dropped phases and why, and update targets when the user changes
  them.
- Once the plan is finished, it stays as a record. Durable formulas
  and results move into the relevant `harness/docs/` file.
