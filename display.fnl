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
    (out:write (tostring (tprint (filter-fields data fields) {:column fields})))
    (out:write "\n\n")))

(fn table-data [data]
  data)

(fn by-ip-table-fields []
  [:client-ip
   :score
   :request-count
   :rule
   :ai-agent
   :reason
   :total-time
   :wall-time])

(fn by-uri-table-fields []
  [:uri
   :score
   :request-count
   :rule
   :total-time
   :wall-time])

(fn render [data out]
  (print-table 
    (table-data data.checks-by-ip) 
    "By IP Address"
    (by-ip-table-fields) 
    out)
  (print-table 
    (table-data data.checks-by-uri) 
    "By URI"
    (by-uri-table-fields) 
    out))

{: render}
