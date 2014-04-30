Upgrading
=========

If you're reading this document, you've most likely been referred here because you are currently using `tell.coffee` from the [github/hubot-scripts](https://github.com/github/hubot-scripts/) repository. That script is deprecated and now being maintained here. This file covers the procedure of upgrading to the new repository.

To upgrade, you first need to remove `"tell.coffee"` from the list in your `hubot-scripts.json` configuration.

Next, add `hubot-tell` to the dependencies section of your `package.json` file:
```javascript
"dependencies": {
  "hubot": ">= 2.5.1",
  "hubot-tell": "*"
}
```

Now, add `hubot-tell` to your `external-scripts.json`:
```javascript
["hubot-tell"]
```

Finally, run `npm install` to install the package.

That's it, you're ready to go! Usage of the script has remained largely the same -- all we've done is added some nifty new features you might like! Check out the [README](https://github.com/lorenzhs/hubot-tell/blob/master/README.md) for more information.
