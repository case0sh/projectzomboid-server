#!/bin/sh

# Ensure User and Group IDs
if [ ! "$(id -u pzombie)" -eq "$UID" ]; then usermod -o -u "$UID" pzombie ; fi
if [ ! "$(id -g pzombie)" -eq "$GID" ]; then groupmod -o -g "$GID" pzombie ; fi

# Install SteamCMD
if [ ! -f /home/steam/steamcmd.sh ]
then
  echo "Downloading SteamCMD..."
  mkdir -p /home/steam/
  cd /home/steam/
  curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
  chown -R pzombie:pzombie /home/steam
  chown -R pzombie:pzombie /data/server-file
fi

# Update pzserver
echo "Updating Project Zomboid..."
if [ "$BRANCH" == "" ]
then
  su pzombie -s /bin/sh -p -c "/home/steam/steamcmd.sh +force_install_dir /data/server-file +login anonymous +app_update 380870 +quit"
else
  su pzombie -s /bin/sh -p -c "/home/steam/steamcmd.sh +force_install_dir /data/server-file +login anonymous +app_update 380870 -beta ${SERVERBRANCH} +quit"
fi

# Symlink
echo "Creating symlink for config folder..."
if [ ! -d /data/config ]
then
  mkdir -p /data/config
fi
su pzombie -s /bin/sh -p -c "ln -s /data/config /home/pzombie/Zomboid"

# Apply server connfiguration
server_ini="/data/config/Server/${SERVER_NAME}.ini"

if [ ! -f $server_ini ]
then
  echo "Updating ${SERVER_NAME}.ini..."
  mkdir -p /data/config/Server
  touch ${server_ini}

  echo "DefaultPort=${SERVER_PORT}" >> ${server_ini}
  echo "Password=${SERVER_PASSWORD}" >> ${server_ini}
  echo "Public=${SERVER_PUBLIC}" >> ${server_ini}
  echo "PublicName=${SERVER_PUBLIC_NAME}" >> ${server_ini}
  echo "PublicDescription=${SERVER_PUBLIC_DESC}" >> ${server_ini}
  echo "RCONPort=${RCON_PORT}" >> ${server_ini}
  echo "RCONPassword=${RCON_PASSWORD}" >> ${server_ini}
  echo "MaxPlayers=${SERVER_MAX_PLAYER}" >> ${server_ini}
  echo "WorkshopItems=2619072426;2392709985;2487022075;2503622437;2732804047;2946221823;2004998206;2544353492;2904920097;2625625421;2592358528;2282429356;2778576730;2732804047;2950902979">> ${server_ini}
  echo "MaxPlayers=${SERVER_MAX_PLAYER}" >> ${server_ini}
  echo "PVP=false" >> ${server_ini}
  echo "AutoCreateUserInWhiteList=true" >> ${server_ini}
  echo "Default=979223735" >> ${server_ini}
  echo "ResetID=979223735" >> ${server_ini}
  echo "Mods=NestedContainer01" >> ${server_ini}
  echo "MinutesPerPage=0.05" >> ${server_ini}
  echo "ServerPlayerID=655759532" >> ${server_ini}
  echo "BloodSplatLifespanDays=5" >> ${server_ini}
  echo "RemovePlayerCorpsesOnCorpseRemoval=false" >> ${server_ini}
  echo "TrashDeleteAll=true" >> ${server_ini}
  echo "MapRemotePlayerVisibility=3" >> ${server_ini}
fi

chown -R pzombie:pzombie /data/config/

# Start server
echo "Launching server..."
cd /data/server-file
su pzombie -s /bin/sh -p -c "./start-server.sh -servername ${SERVER_NAME}  -steamport1 ${STEAMPORT1} -steamport2 ${STEAMPORT2} -adminpassword ${SERVER_ADMIN_PASSWORD}"