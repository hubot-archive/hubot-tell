# Description:
#   Tell Hubot to send a user a message when present in the room
#
# Dependencies:
#   timeago (if HUBOT_TELL_RELATIVE_TIME is set)
#
# Configuration:
#   HUBOT_TELL_ALIASES [optional] - Comma-separated string of command aliases for "tell".
#   HUBOT_TELL_RELATIVE_TIME [boolean] - Set to use relative time strings ("2 hours ago")
#
# Commands:
#   hubot tell <recipients> <some message> - tell <recipients> <some message> next time they are present.
#
# Notes:
#   Case-insensitive prefix matching is employed when matching usernames, so
#   "foo" also matches "Foo" and "foooo".
#   A comma-separated list of recipients can be supplied to relay the message
#   to each of them.
#
# Author:
#   christianchristensen, lorenzhs, xhochy, patcon

config =
  aliases: if process.env.HUBOT_TELL_ALIASES?
    # Split and remove empty array values.
    process.env.HUBOT_TELL_ALIASES.split(',').filter((x) -> x?.length)
  else
    []
  relativeTime: process.env.HUBOT_TELL_RELATIVE_TIME?

module.exports = (robot) ->
  commands = ['tell'].concat(config.aliases)
  commands = commands.join('|')

  REGEX = ///(#{commands})\s+([\w,.-]+):?\s+(.*)///i

  robot.respond REGEX, (msg) ->
    localstorage = JSON.parse(robot.brain.get 'hubot-tell') or {}

    verb = msg.match[1]
    recipients = msg.match[2].split(',').filter((x) -> x?.length)
    message = msg.match[3]

    room = msg.message.user.reply_to || msg.message.user.room
    tellmessage = [msg.message.user.name, new Date(), message]
    if not localstorage[room]?
      localstorage[room] = {}
    for recipient in recipients
      if localstorage[room][recipient]?
        localstorage[room][recipient].push(tellmessage)
      else
        localstorage[room][recipient] = [tellmessage]
    msg.send("Ok, I'll #{verb} #{recipients.join(', ')} '#{message}'.")
    robot.brain.set 'hubot-tell', JSON.stringify(localstorage)
    robot.brain.save()
    return

  # When a user enters, check if someone left them a message
  robot.enter (msg) ->
    localstorage = JSON.parse(robot.brain.get 'hubot-tell') or {}

    if config.relativeTime
      timeago = require('timeago')
    username = msg.message.user.name
    room = msg.message.user.room
    if localstorage[room]?
      for recipient, message of localstorage[room]
        # Check if the recipient matches username
        if username.match new RegExp("^#{recipient}", "i")
          tellmessage = "#{username}: "
          for message in localstorage[room][recipient]
            # Also check that we have successfully loaded timeago
            if config.relativeTime && timeago?
              timestr = timeago(message[1])
            else
              timestr = "at #{message[1].toLocaleString()}"
            tellmessage += "#{message[0]} said #{timestr}: #{message[2]}\r\n"
          delete localstorage[room][recipient]
          robot.brain.set 'hubot-tell', JSON.stringify(localstorage)
          robot.brain.save()
          msg.send(tellmessage)
    return
