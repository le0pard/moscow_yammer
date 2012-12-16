# MosCow Yammer

## Push to couchdb

    couchapp push app.js http://localhost:5984/moscow_yammer
    
## URLs

    http://localhost:5984/moscow_yammer/_design/moscow_yammer/index.html
    
## Vhosts

    vhosts	moscow-yammer.couchdb	
    /moscow_yammer/_design/moscow_yammer/_rewrite
    
    
    http://moscow-yammer.couchdb:5984/
