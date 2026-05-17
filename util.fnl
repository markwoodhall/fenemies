(fn count-f
  [tbl f-pred]
  "Given a table and a predicate function returns a count of rows matching
   the predicate f, i.e. with predicate returning true"
  (accumulate [i 0 _ row (pairs tbl)]
    (if (f-pred row)
        (+ i 1)
        i)))

{: count-f }
