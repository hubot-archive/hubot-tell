# Description:
#   Tell Hubot to send a user a message when present in the room
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_TELL_ALIASES [optional] - Comma-separated string of command aliases for "tell".
#
# Commands:
#   hubot tell <username> <some message> - tell <username> <some message> next time they are present.
#
# Notes:
#   Case-insensitive prefix matching is employed when matching usernames, so
#   "foo" also matches "Foo" and "foooo".
#
# Author:
#   christianchristensen, lorenzhs, xhochy, patcon

config =
  aliases: if process.env.HUBOT_TELL_ALIASES?
    # Split and remove empty array values.
    process.env.HUBOT_TELL_ALIASES.split(',').filter((x) -> x?.length)
  else
    []

module.exports = (robot) ->
  localstorage = {}

  commands = ["tell"].concat(config.aliases)
  commands = commands.join '|'

  REGEX = ///(#{commands})\s+([\w.-]+):?\s+(.*)///i

  robot.respond REGEX, (msg) ->
    datetime = new Date()
    verb = msg.match[1]
    username = msg.match[2]
    message = msg.match[3]
    room = msg.message.user.room
    tellmessage = msg.message.user.name + " @ " + datetime.toLocaleString() + " said: " + message + "\r\n"
    if not localstorage[room]?
      localstorage[room] = {}
    if localstorage[room][username]?
      localstorage[room][username] += tellmessage
    else
      localstorage[room][username] = tellmessage
    msg.send "Ok, I'll #{verb} #{username} '#{message}'."
    return

  # When a user enters, check if someone left them a message
  robot.enter (msg) ->
    username = msg.message.user.name
    room = msg.message.user.room
    if localstorage[room]?
      for recipient, message of localstorage[room]
        # Check if the recipient matches username
        if username.match(new RegExp "^"+recipient, "i")
          tellmessage = username + ": " + localstorage[room][recipient]
          delete localstorage[room][recipient]
          msg.send tellmessage
    return
