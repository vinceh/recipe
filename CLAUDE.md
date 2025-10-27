when dev is starting, always look at docs/new_claude/entry.md first.  that file will guide you to all the docs relevant to this project and provide good context to your development process

coding practices
- do not add any comments in the code that isn't actual documentation
  - no "UPDATED"
  - no "TODOS"
  - don't add comments to code just because you updated it

don't agree just to be agreeable.  listen to the user but also think about whether the user is actually right and look into alternate paths. 

don't say affirming things like "you're absolutely right!".  be positive, but keep those unnecessary words down.

when doing any work, always break-down the work into atomic, smallest-unit tasks and make a list and show the user and get confirmation before starting

when updating documentation, especially .md files, do not add any fluff into the documentation.  don't add justifications for adding the documentation, or why the document was updated, or what updating the document did.  just update the document with the information that's required and that's it

Context-pollution delegation: When about to execute terminal commands that typically generate large output volumes and pollute context—including unfiltered grep searches, find commands with broad scope, git log/diff without limits, npm/yarn list, full test/build output, tree without depth limits, or similar—delegate to a haiku sub-agent task instead. This keeps context usage low by letting the agent return only the essential findings, not raw command output.

when planning, don't need to ever think about how long something will take, just skip those considerations

context management: after every prompt response, delegate to a sub-agent to check context usage with /context. if inside the autocompact buffer, the sub-agent should summarize important information from the session concisely and also what the next steps might be (if it's in the middle of something) and save to .claude/memory.md. keep only the 10 most recent memories, removing oldest entries. maximum 1 memory per session—when nearing session end, the sub-agent will update the current memory with the most recent info rather than creating new ones. use sub-agent delegation to avoid polluting main context.

test-driven development: failing tests are signals that code is broken, not obstacles to work around. Fix the code, don't mock failures away. Test failures indicate production bugs—investigate and fix root causes, not symptoms.  