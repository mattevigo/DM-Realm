# Characters are a Scope of their own, above Campaigns

A Character lives in a seventh top-level folder, Characters, not inside the Campaign it plays in, because a Character can outlive or leave a Campaign (a sequel, a one-shot, a retired Character who comes back). Characters is a Scope: a Character note may link to Reference, Adventures, Homebrew and other Characters, but never to a Campaign, and never mentions one. So a Character carries no table's story into another Campaign, as Homebrew doesn't. What happened to a Character at a table (the belt attuned in Session 21) is written in that Campaign, linking to the Character; the Character's backlinks give its history. This amends [ADR 0001](0001-scope-by-top-level-folder.md): the top-level folders are seven, still fixed.

*Amended by [ADR 0005](0005-the-dms-world-is-a-scope-apart-from-homebrew.md): World is a sixth Scope, in an eighth top-level folder; a Character may link to it.*

## Considered Options

- **Characters inside each Campaign** (the earlier `Campaigns/<campaign>/Characters`). Rejected: a Character playing in a second Campaign belongs to the first one's folder, and its sheet collects that Campaign's story.
- **A shared Characters folder inside Campaigns, in the Campaign Scope.** Rejected: it keeps ADR 0001's six folders, but a Campaign-Scope note may link to anything, so nothing would keep one Campaign's story out of a Character that another Campaign uses.
- **A Characters Scope that may link to Campaigns.** Rejected: the boundary would then protect nothing, and it would only add a folder.

## Consequences

- **One Character, one current Build.** A one-shot that plays Durga at another level uses a separate Character. Before a level-up or rebuild, the current Build is kept as a past Build in the Character's folder.
- **Campaign-only material becomes Homebrew when a Character gains it.** A Character cannot link to a Campaign's own homebrew, so an item or spell made for one Campaign is promoted to Homebrew (by the existing Promotion rule) once a Character holds it.
- **Links into Characters:** Campaigns and DM Tools may link to a Character; Reference, Adventures and Homebrew may not, as they already never name one.
- **Setup and the Workspace Config gain a seventh folder**, with the key `characters`. No Workspace predates this decision (DM Realm is unreleased), so none needs migrating.
