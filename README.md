hubot-tell
==========

Hubot plugin to send a user a message the next time they are present in the room

Installation
------------

Add **hubot-tell** to your `package.json` file:

```javascript
"dependencies": {
  "hubot": ">= 2.5.1",
  "hubot-tell": "*"
}
```

Add **hubot-tell** to your `external-scripts.json`:

```javascript
["hubot-tell"]
```

Run `npm install`

Usage
-----

Assuming your hubot instance is called `hubot`, you can instruct it to relay a message as follows:

`hubot: tell <recipient> <message>`

The message will then be stored and relayed to the recipient as soon as he or she enters the room. Case-insensitive prefix matching is used to match the recipient's nickname. That way, you can make sure that your message will reach its destination, even if the recipient has a different nickname suffix. If you send a message to `foo`, and `foo1` joins the room, the message will be delivered to them.

Original Authors
----------------

Contributions to this script were made by [Chris Christensen](https://github.com/christianchristensen), [Fabio Cantoni](https://github.com/cover), [Uwe L. Korn](https://github.com/xhochy), [BFGeorge9000](https://github.com/BFGeorge9000), [Josh Nichols](https://github.com/technicalpickles), and [Lorenz Hübschle-Schneider](https://github.com/lorenzhs) before it was migrated to this repository. This information was lost during the migration process from the github/hubot-scripts repository, so they shall be listed here instead.
