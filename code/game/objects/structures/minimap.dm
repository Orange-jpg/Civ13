/obj/structure/sign/map
	desc = "A detailed area map for planning operations."
	name = "area map"
	icon_state = "areamap"
	var/image/img
	var/list/overlay_list = list()
/obj/structure/sign/map/New()
	..()
	img = image(icon = 'icons/minimaps.dmi', icon_state = "minimap")

/obj/structure/sign/map/examine(mob/user)
	user << browse(getFlatIcon(img),"window=popup;size=630x630")

/obj/structure/sign/map/attackby(obj/item/I as obj, mob/user as mob)
	if (istype(I, /obj/item/weapon/pen))
		var/nr = ""
		var/ico_dir = 2
		var/c_color = WWinput(user,"Which color do you want to use?","Color","Cancel",list("Cancel","White","Red","Green","Yellow","Blue"))
		switch(c_color)
			if ("Cancel")
				return
			if ("White")
				c_color = COLOR_WHITE
			if ("Red")
				c_color = COLOR_RED
			if ("Green")
				c_color = COLOR_GREEN
			if ("Yellow")
				c_color = COLOR_YELLOW
			if ("Blue")
				c_color = COLOR_BLUE
		var/c_icon = WWinput(user,"Which icon do you want to use?","Icon","Cancel",list("Cancel","Circle","X","Arrow","Number"))
		switch(c_icon)
			if ("Cancel")
				return
			if ("Circle")
				c_icon = "map_circle"
			if ("X")
				c_icon = "map_x"
			if ("Arrow")
				c_icon = "map_arrow"
				ico_dir = WWinput(user,"Choose a direction:","Number","Cancel",list("Cancel","North","South","East","West","Northeast","Northwest","Southeast","Southwest"))
				if (ico_dir == "Cancel")
					return
				else
					ico_dir = text2dir(ico_dir)
			if ("Number")
				nr = WWinput(user,"Choose a number:","Number","Cancel",list("Cancel","1","2","3","4","5","6","7","8","9"))
				if (nr == "Cancel")
					return
				else
					c_icon = "map_number_[nr]"
		var/x_dist = 0
		var/y_dist = 0
		var/c_location = WWinput(user,"Where do you want to place it (column)?","Location","Cancel",list("Cancel","A","B","C","D","E","F","G","H","I","J"))
		var/c_location2 = WWinput(user,"Where do you want to place it (line)?","Location","Cancel",list("Cancel","1","2","3","4","5","6","7","8","9","10"))
		y_dist = 600-(text2num(c_location2)*60)
		switch(c_location)
			if ("A")
				x_dist = 0
			if ("B")
				x_dist = 60*1
			if ("C")
				x_dist = 60*2
			if ("D")
				x_dist = 60*3
			if ("E")
				x_dist = 60*4
			if ("F")
				x_dist = 60*5
			if ("G")
				x_dist = 60*6
			if ("H")
				x_dist = 60*7
			if ("I")
				x_dist = 60*8
			if ("J")
				x_dist = 60*9
		var/image/symbol_ico = image(icon='icons/minimap_effects.dmi', icon_state = c_icon, dir=ico_dir, layer=src.layer+1)
		symbol_ico.pixel_x = x_dist
		symbol_ico.pixel_y = y_dist
		symbol_ico.color = c_color
		overlay_list+=symbol_ico
		img.overlays += symbol_ico
		return
	else
		..()

/obj/structure/sign/map/verb/clear()
	set name = "Clear"
	set category = null
	set src in oview(1)

	if (!ishuman(usr))
		return
	usr << "You clear the map."
	overlay_list = list()
	img.overlays.Cut()

/obj/structure/sign/map/update_icon()
	..()
	img.overlays.Cut()
	for (var/image/I in overlay_list)
		img.overlays += I

/obj/structure/sign/map/attack_hand(mob/user)
	examine(user)

//////////////////////////////////////////

/obj/structure/sign/infopanel
	desc = "A screen with real time information on the location of the squad and vehicles."
	name = "information panel"
	icon = 'icons/obj/computers.dmi'
	icon_state = "info_panel"
	var/slist = "No information available."
	var/faction = "None"

/obj/structure/sign/infopanel/examine(mob/user)
	update_locs()
	do_html(user)

/obj/structure/sign/infopanel/police
	faction = "Police"

/obj/structure/sign/infopanel/proc/update_locs()
	slist = ""
	if (faction == "None")
		return
	for(var/mob/living/human/H in player_list)
		if (H.civilization == faction)
			var/tst = ""
			if (H.stat == UNCONSCIOUS)
				tst = "(Unresponsive)"
			else if (H.stat == DEAD)
				tst = "(Dead)"
			slist += "<br><b>[H.name]</b> at <b>[H.get_coded_loc()]</b> ([H.x],[H.y]) <b><i>[tst]</i></b><br>"
/obj/structure/sign/infopanel/proc/do_html(var/mob/m)

	if (m)

		m << browse({"

		<br>
		<html>

		<head>
		<style>
		[computer_browser_style]
		</style>
		</head>

		<body>

		<script language="javascript">

		function set(input) {
		  window.location="byond://?src=\ref[src];action="+input.name+"&value="+input.value;
		}

		</script>

		<center>
		<big><b>INFORMATION PANEL</b></big><br><br>
		</center>
		[slist]
		</body>
		</html>
		<br>
		"},  "window=artillery_window;border=1;can_close=1;can_resize=1;can_minimize=0;titlebar=1;size=500x500")


/obj/structure/sign/infopanel/attack_hand(mob/user)
	examine(user)
