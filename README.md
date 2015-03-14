First:

```
npm install
npm install -g gulp
```

Then, for production:

```
NODE_ENV=production gulp dist # Compile with minification.
npm start                     # This will not auto-restart: you may want to wrap this with `forever` or similar.
```

Or, for development, run each in a separate terminal session:

```
gulp watch         # Recompile assets on change.
npm run dev        # Restart server on backend code change.
npm run livereload # Automatically reload browser when assets change.
```

Install the LiveReload browser extension to get live reloading behavior.

Then, visit [localhost:8080](http://localhost:8080/).

You can specify a port using the `PORT` environment variable: `PORT=80 npm start`.

On an iPhone, you can save the page as a Web Clip from Safari and access it from the home screen (it removes the browser chrome).
