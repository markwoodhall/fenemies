(local lume (require :lib.lume))
(local tprint (require :lib.tprint))

(fn filter-fields [data fields]
  (icollect [_ single (ipairs data)]
    (lume.pick single (table.unpack fields))))

(fn print-table [data title fields out]
  "print-table will take a table and list of fields and
  print them out on the standard output in table form."
  (when out.write
    (out:write (string.format "%s\n" title))
    (out:write "──────────────\n")
    (out:write (tostring (tprint (filter-fields data fields) {:column fields})))
    (out:write "\n\n")))

(fn concat [t1 t2]
  (each [_ value (ipairs t2)] 
    (table.insert t1 value))
  t1)

(fn table-data [data]
  data)

(fn base-fields-with [w]
  (concat 
    w
    [:request-count
     :total-time
     :wall-time]))

(fn by-ip-table-fields []
  (base-fields-with
   [:client-ip
    :score
    :avg-score
    :total-score]))

(fn by-uri-table-fields []
  (base-fields-with [:uri :total-score :avg-score]))

(fn by-cidr-24-table-fields []
  (base-fields-with  [:cidr-24 :total-score :avg-score]))

(fn by-cidr-16-table-fields []
  (base-fields-with  [:cidr-16 :total-score :avg-score]))

(fn by-user-agent-table-fields []
  (base-fields-with [:user-agent  :total-score :avg-score]))

(fn write [col out]
  (when out.write
    (each [_ i (pairs col)]
      (out:write (.. i "\n")))))

(fn requests-summary [data]
  (let [rule-reasons (string.gsub 
                       (accumulate [o "" _ v (pairs data.checks-by-rule)]
                         (if (and v v.reason (not (= v.reason "")))
                           (.. o v.reason ", ")
                           o))
                       ", $"
                       "")
        bad-ips (accumulate [i 0 _ ip (pairs data.checks-by-ip)]
                  (if (not (= ip.total-rule :ALLOW))
                    (+ i 1)
                    i))
        bad-uas (accumulate [i 0 _ ua (pairs data.checks-by-user-agent)]
                  (if (not (= ua.total-rule :ALLOW))
                    (+ i 1)
                    i))
        bad-uris (accumulate [i 0 _ uri (pairs data.checks-by-uri)]
                  (if (not (= uri.total-rule :ALLOW))
                    (+ i 1)
                    i))
        bad-net-16 (accumulate [i 0 _ net (pairs data.checks-by-cidr-16)]
                     (if (not (= net.total-rule :ALLOW))
                       (+ i 1)
                       i))
        bad-net-24 (accumulate [i 0 _ net (pairs data.checks-by-cidr-24)]
                     (if (not (= net.total-rule :ALLOW))
                       (+ i 1)
                       i))
        bad-networks (+ bad-net-16 bad-net-24)]
    ["SUMMARY"
     "──────────────"
     (.. "Requests:         " 
         data.summary.requests.all " - " 
         data.summary.requests.clean " clean, " 
         data.summary.requests.flagged " flagged")
     (.. "Rules fired:      " 
         (length rule-reasons) 
         " - " rule-reasons)
     (.. "Suspect entities: "
         bad-ips
         " IPs, "
         bad-uas
         " user agents, "
         bad-uris
         " URIs, "
         bad-networks
         " Networks"
         )
     ""]))

(fn render [data out]

  (write
   ["fenemies — log analysis"
    ""
    "This is a diagnostic tool, not an automation tool."
    ""
    "Use the findings to understand your traffic; mitigation decisions are yours."
    ""]
   out)

  (write
    (requests-summary data)
    ;;Suspect entities:   7 IPs, 6 user agents, 13 URIs, 2 networks

    out)
  (print-table
    (table-data data.checks-by-ip) 
    "BY IP"
    (by-ip-table-fields) 
    out)

  ;;(print-table
  ;;  (table-data data.checks-by-user-agent)
  ;;  "BY USER AGENT"
  ;;  (by-user-agent-table-fields)
  ;;  out)

  (print-table 
    (table-data data.checks-by-uri) 
    "BY URI"
    (by-uri-table-fields) 
    out)

  (print-table 
    (table-data data.checks-by-cidr-24) 
    "BY CIDR /24"
    (by-cidr-24-table-fields) 
    out)

  (print-table 
    (table-data data.checks-by-cidr-16) 
    "BY CIDR /16"
    (by-cidr-16-table-fields) 
    out))

{: render}
