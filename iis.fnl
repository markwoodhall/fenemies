(fn parse [line]
  (let [[date time server-ip
         method uri query-string port username client-ip user-agent referer status _ _ _ _ time-taken] 
        (icollect [s (string.gmatch line "[^ ]+")] s)
        [hour minute second] (icollect [l (string.gmatch time "[^:]+")] l)]
    {:date date
     :time time
     :hour hour
     :minute minute
     :second second
     :seconds (+ (* hour 60 60) (* minute 60) second)
     :server-ip server-ip
     :method method
     :url uri
     :query-string query-string
     :port port
     :username username
     :client-ip client-ip
     :user-agent user-agent
     :referer referer
     :status status
     :time-taken time-taken}))

{: parse }
