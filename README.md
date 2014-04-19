hubot-tell
==========

Hubot plugin to send a user a message the next time they are present in the room

Installation
------------

Add **hubot-tell** to your `package.json` file:

```json
"dependencies": {
  "hubot": ">= 2.5.1",
  "hubot-scripts": ">= 2.4.2",
  "hubot-tell": "*"
}
```

Add **hubot-tell** to your `external-scripts.json`:

```json
["hubot-tell"]
```

Run `npm install`

Usage
-----

Assuming your hubot instance is called `hubot`, you can instruct it to relay a message as follows:

`hubot tell <recipient> <message>`

The message will then be stored and relayed to the recipient as soon as he or she enters the room. Case-insensitive prefix matching is used to match the recipient's nickname. That way, you can make sure that your message will reach its destination, even if the recipient has a different nickname suffix. If you send a message to `foo`, and `foo1` joins the room, the message will be delivered to them.

Authors
-------

Contributions to this script were made by @christianchristensen, @cover, @xhochy, @BFGeorge9000, @technicalpickles, and me before it was migrated to this repository. This information was lost during the migration process from the github/hubot-scripts repository, so they shall be listed here instead ;)
