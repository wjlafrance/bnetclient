# BnetClient

BnetClient is a [Battle.net v1](http://en.wikipedia.org/wiki/Battle.net) chat client for iPad.

During the early 2000's there was a large community of software developers reverse engineering the original Battle.net protocol used in Diablo, StarCraft, WarCraft II, and Diablo II. The protocol was well documented and there was lots of information about the architecture and history of the system, but this information has begun to disappear from the internet.

The purpose of this project is to maintain a working example of a chat client written using modern methodologies.

## Features

- Login and chat as Diablo II.
- Remote CheckRevision calculation using BNLS.
- Download files using [Battle.net File Transfer Protocol](http://www.bnetdocs.org/?op=doc&did=5).

## Uncomplete features

- Login as all legacy (pre WarCraft III) clients.
- Hashing CD-Keys locally.
- Display user icons using Icons.bni file. (See `BNCIconsBNI`, `UIImage+TargaData`).

## Architecture

All packet classes derive from `BNCPacket`. Rather than maintaining a list of packet classes, `BNCPacketManager` obtains a list of `BNCPacket` subclasses at runtime.

## Historical Attribution

- [Valhalla Legends ([vL])](http://forum.valhallalegends.com/index.php) - Clan members contributed substantially to the original Battle.net protocol research, and their forum was the canonical location for discussing any development related to Battle.net.
- [StealthBot](http://www.stealthbot.net/forum/) - The most popular Battle.net chat client, written by [Stealth](http://www.stealthbot.net/forum/index.php?/user/1-stealth/) right here in Madison, WI.
- [BnetDocs](http://bhfiles.com/files/Battle.net/bnetdocs/content.html) and [BnetDocs Redux](http://www.bnetdocs.org/) - The best documetation of the Battle.net protocol.
- [Ron Bowes (iago[x86])](http://blog.skullsecurity.org/) - Research into the "new login system" (NLS) used for WarCraft III, original author of [JavaOp](http://www.javaop.com/), and a great mentor.
- [Robert Paveza (MyndFyre[x86])](http://robpaveza.net/) - Author of [JinxBot](https://code.google.com/p/jinxbot/) and it's underlying libraries, and another great mentor.
