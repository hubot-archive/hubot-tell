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

if config.relativeTime
  timeago = require('timeago')

check_messages = (robot, room, username) ->
  localstorage = JSON.parse(robot.brain.get 'hubot-tell') or {}
  tellmessages = []

  robot.logger.debug "hubot-tell: checking msgs in #{room} for #{username}"

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
          tellmessages.push tellmessage
        delete localstorage[room][recipient]

  robot.logger.debug "hubot-tell: there are #{tellmessages.length} messages for #{username}"

  robot.brain.set 'hubot-tell', JSON.stringify(localstorage)
  robot.brain.save()

  return tellmessages

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
      robot.logger.debug "storing message in #{room} for #{recipient}"
      if localstorage[room][recipient]?
        localstorage[room][recipient].push(tellmessage)
      else
        localstorage[room][recipient] = [tellmessage]
    msg.send("Ok, I'll #{verb} #{recipients.join(', ')} '#{message}'.")
    robot.brain.set 'hubot-tell', JSON.stringify(localstorage)
    robot.brain.save()
    return

  robot.hear /.+/i, (msg) ->
    speaker = msg.message.user.name
    room = msg.message.user.reply_to || msg.message.user.room

    for tellmessage in check_messages(robot, room, speaker)
      msg.send tellmessage

  # When a user enters, check if someone left them a message
  robot.enter (msg) ->
    username = msg.message.user.name
    room = msg.message.user.room

    for tellmessage in check_messages(localstorage, room, speaker)
      msg.send tellmessage
