---
type: regex
target: last_message
match: contains
flags: i
---
^(?=[\s\S]*(not|n['’]t|none of|miss)[^\n]{0,160}\bAdventures\b)(?=[\s\S]*(not|n['’]t|none of|miss)[^\n]{0,160}\bHomebrew\b)(?=[\s\S]*(not|n['’]t|none of|miss)[^\n]{0,160}\bCampaigns\b)
