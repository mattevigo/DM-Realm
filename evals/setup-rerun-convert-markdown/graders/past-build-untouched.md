---
type: regex
target: {source: file, path: Characters/Wren/Past_Builds/Wren_01.md}
match: contains
flags: m
---
^```statblock\n(?:[^\n]*\n)*?bestiary: false\n(?![\s\S]*%% statblock)
