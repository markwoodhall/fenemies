(fn parse [args]
  (if (= (length args) 1)
      (case (. args 1)
        "--help" :help
        "-h" :help
        "-?" :help
        "help" :help

        "--version" :version
        "-v" :version

        _ :help)
      (> (length args) 2)
      (case [(. args 1) (. args 2)]
        ["report" "--file"] {:report true :file (. args 3)})))

{: parse }
