# Application Implementation

It is implemented in flask and it will be listeing the port 5000. It will connect to the cluster postgres by using the service of HA proxy.

For deployment reasons, the application will be in charge of the table and user app creation by using [init_db.sql](https://github.com/carlo4002/revolut_interview/blob/main/app/init_db.sql)


## Dependencies ##
### To Install:

    yum install python3 pyhton3-pip DONE
    pip3 install flask_sqlalchemy psycopg2  DONE
    pip3 install flask  DONE

## Assumptions ###

should I avoid special characters in the string ? YES 
- username is bigger than 3 chars and less than 255 chars
- it has no spaces
- not numbers
- no special chars
