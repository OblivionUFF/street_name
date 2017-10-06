#include <a_samp>
#include <a_mysql>
#include <streamer>

#define MAX_STREET (150)
#define MAX_STREET_NAME (32)

new dbHandler;

enum E_STREETDATA
{
	street_id,
	street_name[MAX_STREET_NAME],
	street_direction[32],
	Float: street_location[6], // MinX-Z, MaxX-Z
	Float: plate_location[6], // offset & rot
	Float: sign_location[6], // offset & rot
	Float: text_location[6], // offset & rot
	street_object[3]
}
new street_data[MAX_STREET][E_STREETDATA];

enum TEMP_DATA
{
	bool:in_action,
	edit_mode,
	static_string,
	Float: current_pos[6],
	Float: sign_pos[6],
	Float: plate_pos[6],
	Float: text_pos[6],
	temp_object[3]
}

new player_temp[MAX_PLAYERS][TEMP_DATA];

public OnFilterScriptInit()
{
	dbHandler = mysql_connect("127.0.0.1", "demo", "root", "nopass", 3306, true, 10);
	mysql_tquery(dbHandler, "SELECT * FROM `street_names`", "LoadStreet");
}

forward LoadStreet();
public LoadStreet()
{
	new id;
	for(new i = 0, list = cache_num_rows(); i < list; i++)
	{
		street_data[id][street_id] = cache_get_field_content_int(i, "sqlid");
		cache_get_field_content(i, "name", street_data[id][street_name], dbHandler, MAX_STREET_NAME);
		cache_get_field_content(i, "direction", street_data[id][street_direction], dbHandler, MAX_STREET_NAME);
		street_data[id][street_location][0] = cache_get_field_content_float(i, "minX");
		street_data[id][street_location][1] = cache_get_field_content_float(i, "minY");
		street_data[id][street_location][2] = cache_get_field_content_float(i, "minZ");
		street_data[id][street_location][3] = cache_get_field_content_float(i, "maxX");
		street_data[id][street_location][4] = cache_get_field_content_float(i, "maxY");
		street_data[id][street_location][5] = cache_get_field_content_float(i, "maxZ");
		street_data[id][plate_location][0] = cache_get_field_content_float(i, "plate_offsetX");
		street_data[id][plate_location][1] = cache_get_field_content_float(i, "plate_offsetY");
		street_data[id][plate_location][2] = cache_get_field_content_float(i, "plate_offsetZ");
		street_data[id][plate_location][3] = cache_get_field_content_float(i, "plate_rotX");
		street_data[id][plate_location][4] = cache_get_field_content_float(i, "plate_rotY");
		street_data[id][plate_location][5] = cache_get_field_content_float(i, "plate_rotZ");
		street_data[id][sign_location][0] = cache_get_field_content_float(i, "sign_offsetX");
		street_data[id][sign_location][1] = cache_get_field_content_float(i, "sign_offsetY");
		street_data[id][sign_location][2] = cache_get_field_content_float(i, "sign_offsetZ");
		street_data[id][sign_location][3] = cache_get_field_content_float(i, "sign_rotX");
		street_data[id][sign_location][4] = cache_get_field_content_float(i, "sign_rotY");
		street_data[id][sign_location][5] = cache_get_field_content_float(i, "sign_rotZ");
		street_data[id][text_location][0] = cache_get_field_content_float(i, "text_offsetX");
		street_data[id][text_location][1] = cache_get_field_content_float(i, "text_offsetY");
		street_data[id][text_location][2] = cache_get_field_content_float(i, "text_offsetZ");
		street_data[id][text_location][3] = cache_get_field_content_float(i, "text_rotX");
		street_data[id][text_location][4] = cache_get_field_content_float(i, "text_rotY");
		street_data[id][text_location][5] = cache_get_field_content_float(i, "text_rotZ");

		street_data[id][street_object][0] = CreateDynamicObject(19981, street_data[id][street_location][0], street_data[id][street_location][1], street_data[id][street_location][2], 0.0, 0.0, 0.0, -1, -1, -1, 300.00, 300.00);

		street_data[id][street_object][1] = CreateDynamicObject(18659, street_data[id][sign_location][0], street_data[id][sign_location][1], street_data[id][sign_location][2], street_data[id][sign_location][3], street_data[id][sign_location][4], street_data[id][sign_location][5], -1, -1, -1, 300.00, 300.00);
		SetDynamicObjectMaterialText(street_data[id][street_object][1], 0, street_data[id][street_name], 140, "Calibri", 30, 1, 0xFFFFFFFF, 0x00000000, 1);

		street_data[id][street_object][2] = CreateDynamicObject(18659, street_data[id][text_location][0], street_data[id][text_location][1], street_data[id][text_location][2], street_data[id][text_location][3], street_data[id][sign_location][4], street_data[id][text_location][5], -1, -1, -1, 300.00, 300.00);
		SetDynamicObjectMaterialText(street_data[id][street_object][2], 0, street_data[id][street_direction], 140, "Calibri", 19, 1, 0xFFFFFFFF, 0x00000000, 1);

		id ++;
	}
	return true;
}

forward generate_street(playerid, step);
public generate_street(playerid, step)
{
	SetPVarInt(playerid, "current_step", step);
	switch(step)
	{
		case 0:
		{
			player_temp[playerid][edit_mode] = 1;
			player_temp[playerid][temp_object][0] = CreateDynamicObject(19981, player_temp[playerid][current_pos][0], player_temp[playerid][current_pos][1], player_temp[playerid][current_pos][2], 0.0, 0.0, 0.0, -1, -1, -1, 300.00, 300.00);
			EditDynamicObject(playerid, player_temp[playerid][temp_object][0]);
		}
		case 1:
		{
			player_temp[playerid][edit_mode] = 2;
			player_temp[playerid][temp_object][1] = CreateDynamicObject(18659, player_temp[playerid][current_pos][0], player_temp[playerid][current_pos][1], player_temp[playerid][current_pos][2], 0.0, 0.0, 0.0, -1, -1, -1, 300.00, 300.00);
			SetDynamicObjectMaterialText(player_temp[playerid][temp_object][1], 0, "Direction", 140, "Calibri", 30, 1, 0xFFFFFFFF, 0x00000000, 1);
			EditDynamicObject(playerid, player_temp[playerid][temp_object][1]);
		}
		case 2:
		{
			player_temp[playerid][edit_mode] = 3;
			player_temp[playerid][temp_object][2] = CreateDynamicObject(18659, player_temp[playerid][current_pos][0], player_temp[playerid][current_pos][1], player_temp[playerid][current_pos][2], 0.0, 0.0, 0.0, -1, -1, -1, 300.00, 300.00);
			SetDynamicObjectMaterialText(player_temp[playerid][temp_object][2], 0, "StreetName", 140, "Calibri", 30, 1, 0xFFFFFFFF, 0x00000000, 1);
			EditDynamicObject(playerid, player_temp[playerid][temp_object][2]);
		}
		default:
		{
			new query[512];
			mysql_format(dbHandler, query, sizeof(query), "INSERT INTO `street_names` (name, minX, minY, minZ, maxX, maxY, maxZ) VALUES ('%s',%f,%f,%f,%f,%f,%f)",
			player_temp[playerid][current_pos][0],
			player_temp[playerid][current_pos][1],
			player_temp[playerid][current_pos][2],
			player_temp[playerid][current_pos][3],
			player_temp[playerid][current_pos][4],
			player_temp[playerid][current_pos][5]
			);
			mysql_query(dbHandler, query, "insert_street", "d", playerid);
		}
	}
	return 0;
}

Float: abs(Float: angel)
{
   return ((angel < 0) ? (angel * -1) : (angel));
}

stock returnAngel(playerid)
{
	new Float: Velocity[3], string[32];
	GetPlayerVelocity(playerid, Velocity[0], Velocity[1], Velocity[2]);
	if(Velocity[0] == 0.0 && Velocity[1] == 0.0)
	{
		format(string, 32, "CENTRAL");
	}
	else
	{
		if(abs(Velocity[1])>abs(Velocity[0]))
		{
			if(Velocity[1] > 0)
			{
				format(string, 32, "NORTH");
			}
			else
			{
				format(string, 32, "SOUTH");
			}
		}
		else
		{
			if(Velocity[0] > 0)
			{
				format(string, 32, "EAST");
			}
			else
			{
				format(string, 32, "WEST");
			}
		}
	}
	return string;
}

stock street_free_slot()
{
	for(new S = 0; S < MAX_STREET; S++)
	{
		if(street_data[S][street_id] == 0)
		{
			return S;
		}
	}
	return -1;
}

forward insert_street(playerid);
public insert_street(playerid)
{
	new id = street_free_slot();
	street_data[id][street_id] = cache_insert_id();

	street_data[id][plate_location][0] = player_temp[playerid][plate_pos][0];
	street_data[id][plate_location][1] = player_temp[playerid][plate_pos][1];
	street_data[id][plate_location][2] = player_temp[playerid][plate_pos][2];
	street_data[id][plate_location][3] = player_temp[playerid][plate_pos][3];
	street_data[id][plate_location][4] = player_temp[playerid][plate_pos][4];
	street_data[id][plate_location][5] = player_temp[playerid][plate_pos][5];

	street_data[id][sign_location][0] = player_temp[playerid][sign_pos][0];
	street_data[id][sign_location][1] = player_temp[playerid][sign_pos][1];
	street_data[id][sign_location][2] = player_temp[playerid][sign_pos][2];
	street_data[id][sign_location][3] = player_temp[playerid][sign_pos][3];
	street_data[id][sign_location][4] = player_temp[playerid][sign_pos][4];
	street_data[id][sign_location][5] = player_temp[playerid][sign_pos][5];

	street_data[id][text_location][0] = player_temp[playerid][text_pos][0];
	street_data[id][text_location][1] = player_temp[playerid][text_pos][1];
	street_data[id][text_location][2] = player_temp[playerid][text_pos][2];
	street_data[id][text_location][3] = player_temp[playerid][text_pos][3];
	street_data[id][text_location][4] = player_temp[playerid][text_pos][4];
	street_data[id][text_location][5] = player_temp[playerid][text_pos][5];

	format(street_data[id][street_name], player_temp[playerid][static_string]);

	format(street_data[id][street_direction], 128, "%d %s", 1000+street_data[id][street_id], returnAngel(playerid));

	street_data[id][street_object][0] = CreateDynamicObject(19981, street_data[id][plate_location][0], street_data[id][plate_location][1], street_data[id][plate_location][2], street_data[id][plate_location][3], street_data[id][plate_location][4], street_data[id][plate_location][5], -1, -1, -1, 300.00, 300.00);

	street_data[id][street_object][1] = CreateDynamicObject(18659, street_data[id][sign_location][0], street_data[id][sign_location][1], street_data[id][sign_location][2], street_data[id][sign_location][3], street_data[id][sign_location][4], street_data[id][sign_location][5], -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterialText(street_data[id][street_object][1], 0, street_data[id][street_name], 140, "Calibri", 30, 1, 0xFFFFFFFF, 0x00000000, 1);

	street_data[id][street_object][2] = CreateDynamicObject(18659, street_data[id][text_location][0], street_data[id][text_location][1], street_data[id][text_location][2], street_data[id][text_location][3], street_data[id][sign_location][4], street_data[id][text_location][5], -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterialText(street_data[id][street_object][2], 0, street_data[id][street_direction], 140, "Calibri", 19, 1, 0xFFFFFFFF, 0x00000000, 1);
	reset_temp(playerid);
	SaveStreet(street_data[id][street_id]);
}

forward SaveStreet(id);
public SaveStreet(id)
{
	new query[300];
	mysql_format(dbHandler, query, sizeof(query), "UPDATE street_names SET name = '%s', direction = '%s' WHERE sqlid = %i", street_data[id][street_name], street_data[id][street_direction], id);
	mysql_query(dbHandler, query);

	mysql_format(dbHandler, query, sizeof(query), "UPDATE street_names SET plate_offsetX = %f, plate_offsetY = %f, plate_offsetZ = %f, plate_rotX = %f, plate_rotY = %f, plate_rotZ = %f WHERE sqlid = %i", street_data[id][plate_location][0], street_data[id][plate_location][1], street_data[id][plate_location][2], street_data[id][plate_location][3], street_data[id][plate_location][4], street_data[id][plate_location][5], id);
	mysql_query(dbHandler, query);

	mysql_format(dbHandler, query, sizeof(query), "UPDATE street_names SET sign_offsetX = %f, sign_offsetY = %f, sign_offsetZ = %f, sign_rotX = %f, sign_rotY = %f, sign_rotZ = %f WHERE sqlid = %i", street_data[id][sign_location][0], street_data[id][sign_location][1], street_data[id][sign_location][2], street_data[id][sign_location][3], street_data[id][sign_location][4], street_data[id][sign_location][5], id);
	mysql_query(dbHandler, query);

	mysql_format(dbHandler, query, sizeof(query), "UPDATE street_names SET text_offsetX = %f, text_offsetY = %f, text_offsetZ = %f, text_rotX = %f, text_rotY = %f, text_rotZ = %f WHERE sqlid = %i", street_data[id][text_location][0], street_data[id][text_location][1], street_data[id][text_location][2], street_data[id][text_location][3], street_data[id][sign_location][4], street_data[id][text_location][5], id);
	mysql_query(dbHandler, query);
}

stock reset_temp(playerid)
{
	player_temp[playerid][in_action] = false;
	player_temp[playerid][edit_mode] = 0;

	format(player_temp[playerid][static_string], "None");
	for(new addr = 0; addr < 3; addr++)
		player_temp[playerid][current_pos][addr] = 0.0;
		if(IsValidDynamicObject(player_temp[playerid][temp_object][addr])) DestroyDynamicObject(player_temp[playerid][temp_object][addr]);
		player_temp[playerid][temp_object][addr] = INVALID_OBJECT_ID;
}

public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(response == EDIT_RESPONSE_FINAL)
	{
		switch(player_temp[playerid][edit_mode])
		{
			case 1:
			{
				player_temp[playerid][plate_pos][0] = x;
				player_temp[playerid][plate_pos][1] = y;
				player_temp[playerid][plate_pos][2] = z;
				player_temp[playerid][plate_pos][3] = rx;
				player_temp[playerid][plate_pos][4] = ry;
				player_temp[playerid][plate_pos][5] = rz;
			}
			case 2:
			{
				player_temp[playerid][sign_pos][0] = x;
				player_temp[playerid][sign_pos][1] = y;
				player_temp[playerid][sign_pos][2] = z;
				player_temp[playerid][sign_pos][3] = rx;
				player_temp[playerid][sign_pos][4] = ry;
				player_temp[playerid][sign_pos][5] = rz;
			}
			case 3:
			{
				player_temp[playerid][text_pos][0] = x;
				player_temp[playerid][text_pos][1] = y;
				player_temp[playerid][text_pos][2] = z;
				player_temp[playerid][text_pos][3] = rx;
				player_temp[playerid][text_pos][4] = ry;
				player_temp[playerid][text_pos][5] = rz;
			}
		}
		generate_street(playerid, GetPVarInt(playerid, "current_step")+1);
	}
	if(response == EDIT_RESPONSE_CANCEL)
	{
		if(player_temp[playerid][edit_mode])
		{
			reset_temp(playerid);
		}
	}
	return 1;
}

stock GetPlayerStreet(playerid, zone[], length)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    for(new i = 0; i != MAX_STREET; i++)
    {
        if(x >= street_data[i][street_location][0] && x <= street_data[i][street_location][3] && y >= street_data[i][street_location][1] && y <= street_data[i][street_location][4])
        {
            return format(zone, length, street_data[i][street_name], 0);
        }
    }
    return format(zone, length, "Unknown", 0);
}

stock GetStreetID(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    for(new i = 0; i != MAX_STREET; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 15.0, street_data[i][street_location][0], street_data[i][street_location][2], street_data[i][street_location][3]) || IsPlayerInRangeOfPoint(playerid, 15.0, street_data[i][street_location][3], street_data[i][street_location][4], street_data[i][street_location][5]))
        {
            return i;
        }
    }
    return -1;
}

CMD:create_street(playerid, params[])
{
	new Float: player_pos[3];
	if(player_temp[playerid][in_action])
	{
	    if(sscanf(params,"s[32]", params[0]))
		{
			return SendClientMessage(playerid, -1, "USAGE: /create_street [street_name]");
		}
		GetPlayerPos(playerid, player_pos[0], player_pos[1], player_pos[2]);
		player_temp[playerid][current_pos][3] = player_pos[0];
		player_temp[playerid][current_pos][4] = player_pos[1];
		player_temp[playerid][current_pos][5] = player_pos[2];
		format(player_temp[playerid][static_string], params[0]);
		generate_street(playerid, 0);
	}
	else
	{
		GetPlayerPos(playerid, player_pos[0], player_pos[1], player_pos[2]);
		player_temp[playerid][current_pos][0] = player_pos[0];
		player_temp[playerid][current_pos][1] = player_pos[1];
		player_temp[playerid][current_pos][2] = player_pos[2];
		player_temp[playerid][in_action] = true;
		SendClientMessage(playerid, -1, "SERVER: Please stand at any corner or the end of street.");
		SendClientMessage(playerid, -1, "SERVER: Take more 10 sprints after redo the command.");
	}
	return true;
}

CMD:streetname(playerid, params[])
{
	new str[64], street[32];
	GetPlayerStreet(playerid, street, 32);
	format(str, sizeof(str), "SERVER: YOU ARE NOW STANDING ON %s, %s", street_data[ GetStreetID(playerid) ][street_direction], street);
	SendClientMessage(playerid, -1, str);
	return true;
}

