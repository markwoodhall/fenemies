(local args (require :args))
(local display (require :display))
(local report (require :report))

(fn display-help []
  (io.stderr:write
   (.. "Usage: fenemies [options] [command]\n\n"
       "    fenemies is a tail like tool used to analyse your web server logs and "
       "    interact with various firewalls, to block your enemies. "
       "\n"
       "    Options\n"
       "    [-v, --version                       Display fenemies version number]\n"
       "\n"
       "    Help:\n"
       "    Set VERBOSE environment variable for info level logging\n"
       )))

(fn main []
  (let [arguments (args.parse arg)]
    (if arguments.help
        (display-help)
        arguments.version
        (display.render "0.0.0" io.stdout)
        arguments.report
        (display.render (report.build (?. arguments.file 1)) io.stdout))))

;; give better tracebacks in development
(xpcall main #(case (pcall require :fennel)
                (true {: traceback}) (print $ (traceback))
                _ (print $ (debug.traceback))))
