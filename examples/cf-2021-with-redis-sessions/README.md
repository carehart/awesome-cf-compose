## Compose sample application
### ColdFusion with redis sessions

Complete Readme text to be developed
- noticed how on calling setsession.cfm, a session.test var will be created and incremented when executed
- and getsession.cfm will show that value
- restarting either the colfusion or redis services will show that the session var persists across such restarts
- if the external: true option is used in defining the redis volume, then the session will persist even across a compose down/up