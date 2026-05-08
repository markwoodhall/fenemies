(fn info [...]
  (when (os.getenv "VERBOSE")
    (io.stdout:write ...)))

(fn warn [...]
  (when (not (os.getenv "SILENT"))
    (io.stdout:write ...)))

(fn error [...]
  (io.stderr:write ...))

{: info : warn : error}
