(local lume (require :lib.lume))
(local tprint (require :lib.tprint))

(fn filter-fields [data fields]
  (icollect [_ single (ipairs data)]
    (lume.pick single (table.unpack fields))))

(fn print-table [data title fields out]
  "print-table will take a table and list of fields and
  print them out on the standard output in table form."
  (when out.write
    (out:write (string.format "%s\n\n" title))
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
  [:client-ip
   :score
   :request-count
   :total-time
   :wall-time])

(fn by-uri-table-fields []
  (base-fields-with [:uri :total-score :avg-score]))

(fn by-cidr-24-table-fields []
  (base-fields-with  [:cidr-24 :total-score :avg-score]))

(fn by-cidr-16-table-fields []
  (base-fields-with  [:cidr-16 :total-score :avg-score]))

(fn by-user-agent-table-fields []
  (base-fields-with [:user-agent  :total-score :avg-score]))

(fn render [data out]

  (when out.write
    (out:write 
      "fenemies has analysed your log file and produced the following report.\n\n")
    (out:write 
      "Note. fenemies isn't intended to be used as a blind automation tool for blocking requests, rather as\n")
    (out:write 
      "a tool to help understand your system from a \"usage\" perspective.\n\n"))

  (print-table 
    (table-data data.checks-by-ip) 
    "Analysis by client IP address"
    (by-ip-table-fields) 
    out)

  (print-table 
    (table-data data.checks-by-user-agent) 
    "Analysis by User Agent"
    (by-user-agent-table-fields) 
    out)

  (print-table 
    (table-data data.checks-by-uri) 
    "Analysis by URI"
    (by-uri-table-fields) 
    out)

  (print-table 
    (table-data data.checks-by-cidr-24) 
    "Analysis by CIDR /24"
    (by-cidr-24-table-fields) 
    out)

  (print-table 
    (table-data data.checks-by-cidr-16) 
    "Analysis by CIDR /16"
    (by-cidr-16-table-fields) 
    out))

{: render}
