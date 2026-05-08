(local log (require :log))
(local robots (require :robots))
(local iis (require :iis))

(fn deny-user-agent [v]
  (let [compare (string.lower v)]
    (accumulate [o 0 _ ua (ipairs robots)]
      (if (not (= 100 o)) 
        (if (string.find compare (string.lower ua))
          100
          o)
        o))))

(fn check [line]
  (log.info "Checking line " line "\n")
  (let [parts (iis.parse line)
        {: client-ip : user-agent } parts
        score (deny-user-agent user-agent)
        rule (if (>= score 100)
               :DENY
               :ALLOW)
        _ (set parts.score score)
        _ (set parts.rule rule)]
    (log.info (. parts :rule) " " client-ip " " user-agent "\n")
    parts))

{: check }
