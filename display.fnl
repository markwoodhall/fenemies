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

(fn table-title []
  "Report")

(fn table-fields []
  [:client-ip
   :score
   :request-count
   :rule])

(fn render [data out]
  (print-table 
    (table-data data) 
    (table-title) 
    (table-fields) 
    out))

{: render}
