# OM(Ops Manager) Demo

**[&rarr; OM setup](#step1-om-setup)**  
**[&rarr; Agent setup](#step2-agent-setup)**  
**[&rarr; Demo](#step-3-demo)**

As a docker-based OM demo, it purposes to

- provide one-stop package (appDB RS, OM, OM&agent-managed RS, backup)
- be easy to set up with maximum automation (minimal human intervention)
- be portable

### Requisites

- `docker`
- `docker-compose` (don't use partially compatible `docker compose`)

**Docker engine minimal req.**

- RAM: min(40G, host RAM max)
- CPU: min(22, host CPU max)
- Storage: 256+G

**Tested & Verified**

- Macbook Pro M4
- AWS AMI2023 ec2
  > Macbook Pro is meant to be for local trials for practices.  
  > Rosetta's x86_64 virtualization is too sqeaky for live demo let alone the lack of resource.

### Summary

![containers](./readme/container_composition.png)

| entity     | container            | role                      | deploy topology | arch & os                                  |
| ---------- | -------------------- | ------------------------- | --------------- | ------------------------------------------ |
| OM         | om                   | Ops Manager               | standalone      | ubuntu:22.04 x86_64                        |
| appDB      | appdb1,appdb2,appdb3 | OM-backing appDB          | RS              | mongodb:mongodb-enterprise-server:8.0-ubi8 |
| Agent      | ag1,ag2,ag3          | agent-manged user cluster | RS              | arm64: ubuntu:22.04, x86_64: ubuntu:24.04  |
| Blockstore | bkst                 | backup snapshot storage   | standalone      | ubuntu:22.04 arm64/x86_64                  |

## Step1 OM setup

This includes OM and its backing appDB

### Build images

```
docker-compose --profile om build
```

> To prevent any timing issue chancing to occur during startup,  
> build images first separately from starting containers.

This will build out 2 images.

- appDB: `appdb:8.2`
- OM: `opsmanager:8`

### Start appDB

```
docker-compose --profile appdb up -d
```

This will start and initialize 3 containers in order.

- `appdb1`
- `appdb2`
- `appdb3`

> RS: `omrs`  
> users: id&pwd
>
> - `super:super1234`
> - `admin:admin1234`
> - `pm:pm1234`

Check if RS is successfully loaded.  
For example: (in the following example, any container of `appdb1`, `appdb2`, `appdb3` should work)

```
[ec2-user@ip-172-31-16-169 ~]$ docker exec -it appdb1 /bin/bash

bash-4.4# mongosh "mongodb://pm:pm1234@appdb1,appdb2,appdb3"

Current Mongosh Log ID:	68d3ab6a844e6c1baece5f46
Connecting to:		mongodb://<credentials>@appdb1,appdb2,appdb3/?appName=mongosh+2.5.8
Using MongoDB:		8.2.0
Using Mongosh:		2.5.8

For mongosh info see: https://www.mongodb.com/docs/mongodb-shell/

------
   The server generated these startup warnings when booting
   2025-09-24T02:48:23.677+09:00: You are running this process as the root user, which is not recommended
------

Enterprise omrs [primary] test> db.isMaster().primary
appdb1:27017
Enterprise omrs [primary] test> rs.status()
{
  set: 'omrs',
  date: ISODate('2025-09-24T08:27:44.224Z'),
  myState: 1,
  term: Long('3'),
  syncSourceHost: '',
  syncSourceId: -1,
  heartbeatIntervalMillis: Long('30000'),
  majorityVoteCount: 2,
  writeMajorityCount: 2,
  votingMembersCount: 3,
  writableVotingMembersCount: 3,
  optimes: {
    lastCommittedOpTime: { ts: Timestamp({ t: 1758702463, i: 15 }), t: Long('3') },
    lastCommittedWallTime: ISODate('2025-09-24T08:27:43.533Z'),
    readConcernMajorityOpTime: { ts: Timestamp({ t: 1758702463, i: 15 }), t: Long('3') },
    appliedOpTime: { ts: Timestamp({ t: 1758702463, i: 15 }), t: Long('3') },
    durableOpTime: { ts: Timestamp({ t: 1758702463, i: 15 }), t: Long('3') },
    writtenOpTime: { ts: Timestamp({ t: 1758702463, i: 15 }), t: Long('3') },
    lastAppliedWallTime: ISODate('2025-09-24T08:27:43.533Z'),
    lastDurableWallTime: ISODate('2025-09-24T08:27:43.533Z'),
    lastWrittenWallTime: ISODate('2025-09-24T08:27:43.533Z')
  },
  lastStableRecoveryTimestamp: Timestamp({ t: 1758702452, i: 1 }),
  electionCandidateMetrics: {
    lastElectionReason: 'electionTimeout',
    lastElectionDate: ISODate('2025-09-23T17:48:34.284Z'),
    electionTerm: Long('3'),
    lastCommittedOpTimeAtElection: { ts: Timestamp({ t: 0, i: 0 }), t: Long('-1') },
    lastSeenWrittenOpTimeAtElection: { ts: Timestamp({ t: 1758649576, i: 11 }), t: Long('2') },
    lastSeenOpTimeAtElection: { ts: Timestamp({ t: 1758649576, i: 11 }), t: Long('2') },
    numVotesNeeded: 2,
    priorityAtElection: 1,
    electionTimeoutMillis: Long('10000'),
    numCatchUpOps: Long('0'),
    newTermStartDate: ISODate('2025-09-23T17:48:34.292Z'),
    wMajorityWriteAvailabilityDate: ISODate('2025-09-23T17:48:34.301Z')
  },
  members: [
    {
      _id: 0,
      name: 'appdb1:27017',
      health: 1,
      state: 1,
      stateStr: 'PRIMARY',
      uptime: 52761,
      optime: { ts: Timestamp({ t: 1758702463, i: 15 }), t: Long('3') },
      optimeDate: ISODate('2025-09-24T08:27:43.000Z'),
      optimeWritten: { ts: Timestamp({ t: 1758702463, i: 15 }), t: Long('3') },
      optimeWrittenDate: ISODate('2025-09-24T08:27:43.000Z'),
      lastAppliedWallTime: ISODate('2025-09-24T08:27:43.533Z'),
      lastDurableWallTime: ISODate('2025-09-24T08:27:43.533Z'),
      lastWrittenWallTime: ISODate('2025-09-24T08:27:43.533Z'),
      syncSourceHost: '',
      syncSourceId: -1,
      infoMessage: '',
      electionTime: Timestamp({ t: 1758649714, i: 1 }),
      electionDate: ISODate('2025-09-23T17:48:34.000Z'),
      configVersion: 1,
      configTerm: 3,
      self: true,
      lastHeartbeatMessage: ''
    },
    {
      _id: 1,
      name: 'appdb2:27017',
      health: 1,
      state: 2,
      stateStr: 'SECONDARY',
      uptime: 52759,
      optime: { ts: Timestamp({ t: 1758702453, i: 4 }), t: Long('3') },
      optimeDurable: { ts: Timestamp({ t: 1758702453, i: 4 }), t: Long('3') },
      optimeWritten: { ts: Timestamp({ t: 1758702453, i: 4 }), t: Long('3') },
      optimeDate: ISODate('2025-09-24T08:27:33.000Z'),
      optimeDurableDate: ISODate('2025-09-24T08:27:33.000Z'),
      optimeWrittenDate: ISODate('2025-09-24T08:27:33.000Z'),
      lastAppliedWallTime: ISODate('2025-09-24T08:27:43.533Z'),
      lastDurableWallTime: ISODate('2025-09-24T08:27:43.533Z'),
      lastWrittenWallTime: ISODate('2025-09-24T08:27:43.533Z'),
      lastHeartbeat: ISODate('2025-09-24T08:27:34.296Z'),
      lastHeartbeatRecv: ISODate('2025-09-24T08:27:39.295Z'),
      pingMs: Long('0'),
      lastHeartbeatMessage: '',
      syncSourceHost: 'appdb1:27017',
      syncSourceId: 0,
      infoMessage: '',
      configVersion: 1,
      configTerm: 3
    },
    {
      _id: 2,
      name: 'appdb3:27017',
      health: 1,
      state: 2,
      stateStr: 'SECONDARY',
      uptime: 52759,
      optime: { ts: Timestamp({ t: 1758702453, i: 4 }), t: Long('3') },
      optimeDurable: { ts: Timestamp({ t: 1758702453, i: 4 }), t: Long('3') },
      optimeWritten: { ts: Timestamp({ t: 1758702453, i: 4 }), t: Long('3') },
      optimeDate: ISODate('2025-09-24T08:27:33.000Z'),
      optimeDurableDate: ISODate('2025-09-24T08:27:33.000Z'),
      optimeWrittenDate: ISODate('2025-09-24T08:27:33.000Z'),
      lastAppliedWallTime: ISODate('2025-09-24T08:27:43.533Z'),
      lastDurableWallTime: ISODate('2025-09-24T08:27:43.533Z'),
      lastWrittenWallTime: ISODate('2025-09-24T08:27:43.533Z'),
      lastHeartbeat: ISODate('2025-09-24T08:27:34.295Z'),
      lastHeartbeatRecv: ISODate('2025-09-24T08:27:39.295Z'),
      pingMs: Long('0'),
      lastHeartbeatMessage: '',
      syncSourceHost: 'appdb1:27017',
      syncSourceId: 0,
      infoMessage: '',
      configVersion: 1,
      configTerm: 3
    }
  ],
  ok: 1,
  '$clusterTime': {
    clusterTime: Timestamp({ t: 1758702463, i: 15 }),
    signature: {
      hash: Binary.createFromBase64('Aij6O6v9cJiP26qj8eZkWRW394I=', 0),
      keyId: Long('7553332144777461765')
    }
  },
  operationTime: Timestamp({ t: 1758702463, i: 15 })
}
Enterprise omrs [primary] test>
```

### Start OM

```
docker-compose --profile om up -d

```

> Be sure to start `om` in separate after `appDB`.  
> Otherwise, `om` may fail tyring to authenticate with `appDB` too soon before RS is initialized.

This will start & initialize OM container: `om`  
Check if `om` successfully gets ready:

```
[ec2-user@ip-172-31-16-169 ~]$ docker logs -f om

tput: No value for $TERM and no -T specified
Migrate Ops Manager data
Running migrations...[ OK ]
Starting Ops Manager server
Instance 0 starting..........[ OK ]
tput: No value for $TERM and no -T specified
Starting pre-flight checks
Successfully finished pre-flight checks

Start Backup Daemon...[ OK ]
```

> You must wait for the last line, "`Start Backup Daemon...[ OK ]`"  
> before proceeding to the next step. (it will take a while)

## Step2 Agent setup

This includes OM agent and backup blockstore.

### Prepare for agent build

```
cp env.template .env
```

`.env` file:

```
# find values from OpsManager > Deployment > Agents > Downloads & Settings
mmsGroupId=
mmsApiKey=

# set arm64 for Apple silicon(default: amd64 for x86_64)
ARCH=
```

Fill in 3 values before building agent image.

- `mmsGroupId`: OM project ID (value from OM UI)
- `mmsApiKey`: Project API Key (value from OM UI)
- `ARCH`: set `arm64` if running on Macbook apple silicons or let it be unset

Connect to `http://localhost:8080` from a browser on your local host.

- sign up
- go to `Deployment` in the navi panel > `Agents` tab > `Downloads & Settings`
- pull down `Select your operating system`
- choose `Debian Ubuntu 24.x - DEB (x86_64)` iff your host is a x86_64 system
- or choose `Ubuntu 20.x/22.x - DEB (ARM)` for your arm64 host

![agent download](./readme/agent_download.png)

- copy and paste 2 params(`mmsGroupId`, `mmsApiKey`) into `.env` file
  > You have to click `+Generate Key` and generate a new apiKey from the popup if for the first time.

![agent params](./readme/agent_params.png)

Your `.env` file should look like this:

```
# find values from OpsManager > Deployment > Agents > Downloads & Settings
mmsGroupId=68d2d49a7eef554eca85c25d
mmsApiKey=68d2d9cb7eef554eca85d5d2a19e1dfcd972ee9174c7207d27c3064c

# set host arch & ubuntu version iff running on Macbook Mx series(arm64)
ARCH=
```

> Leave `ARCH` blank unless you're running on arm64 host.

### Build images

```
docker-compose --profile agent build
```

This will build an image: `om-agent:8`

### Start agents & blockstore

```
docker-compose --profile agent up -d
```

This will start 3 agent containers and 1 blockstore for backup

- `ag1`
- `ag2`
- `ag3`
- `bkst`: standalone mongodb ea with no id/pwd set up

> Why now start `bkst`, not earlier along with `om`?  
> just `bkst` is added last to the project. There's no technical reason.

## Step 3 Demo

I believe I'm the last person to ask about `OM` operation.  
So I don't have courage to talk in lengths.

Just guessing it's better to showcase the following essential operations along with other foundational features you have expertise with.

### Add `New Replica Set`

You MUST be an expert !!

### Add `Existing MongoDB Deployment`

You don't need additional RS to demo this feature.  
Remove the newly added RS from OM then you have an old RS, `Existing MongoDB Deployment` to add to OM for the demo.

![remove from OM](./readme/remove_rs_from_om.png)

> Choose `Completely remove from Ops Manager` from the popup.

### Backup

Use `/var/lib/mongodb/backup` for `HEAD database folder`(HEAD directory)

> it's `OM` folder

![head DB folder](./readme/headDB_folder.png)

Choose `Configure A Blockstore`

![choose blockstore](./readme/choose_blockstore.png)

> Don't forget `bkst` is a standalone MongoDB EA node.

Set `<hostname>:<port>` to `bkst:27017` and leave other fields blank.

> Remember `bkst` is not set up with any credential?

![backup config](./readme/backup_config.png)

Then `Save`

All set !!  
The rest is yours.

![all set](./readme/backup_ready.png)
