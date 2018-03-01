/obj/machinery/pipedispenser
	name = "Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = 1
	anchored = 1
	var/unwrenched = 0
	var/wait = 0

/obj/machinery/pipedispenser/attack_hand(mob/user)
	if(..())
		return 1
		
	interact(user)
	
/obj/machinery/pipedispenser/attack_ghost(mob/user)
	interact(user)
			
/obj/machinery/pipedispenser/interact(mob/user)
	var/dat = {"
<b>Regular pipes:</b><BR>
<A href='?src=[UID()];make=0;dir=1'>Pipe</A><BR>
<A href='?src=[UID()];make=1;dir=5'>Bent Pipe</A><BR>
<A href='?src=[UID()];make=5;dir=1'>Manifold</A><BR>
<A href='?src=[UID()];make=8;dir=1'>Manual Valve</A><BR>
<A href='?src=[UID()];make=35;dir=1'>Digital Valve</A><BR>
<A href='?src=[UID()];make=20;dir=1'>Pipe Cap</A><BR>
<A href='?src=[UID()];make=19;dir=1'>4-Way Manifold</A><BR>
<A href='?src=[UID()];make=18;dir=1'>Manual T-Valve</A><BR>
<A href='?src=[UID()];make=38;dir=1'>Digital T-Valve</A><BR>
<b>Supply pipes:</b><BR>
<A href='?src=[UID()];make=24;dir=1'>Pipe</A><BR>
<A href='?src=[UID()];make=25;dir=5'>Bent Pipe</A><BR>
<A href='?src=[UID()];make=28;dir=1'>Manifold</A><BR>
<A href='?src=[UID()];make=32;dir=1'>Pipe Cap</A><BR>
<A href='?src=[UID()];make=30;dir=1'>4-Way Manifold</A><BR>
<b>Scrubbers pipes:</b><BR>
<A href='?src=[UID()];make=26;dir=1'>Pipe</A><BR>
<A href='?src=[UID()];make=27;dir=5'>Bent Pipe</A><BR>
<A href='?src=[UID()];make=29;dir=1'>Manifold</A><BR>
<A href='?src=[UID()];make=33;dir=1'>Pipe Cap</A><BR>
<A href='?src=[UID()];make=31;dir=1'>4-Way Manifold</A><BR>
<b>Devices:</b><BR>
<A href='?src=[UID()];make=23;dir=1'>Universal Pipe Adapter</A><BR>
<A href='?src=[UID()];make=4;dir=1'>Connector</A><BR>
<A href='?src=[UID()];make=7;dir=1'>Unary Vent</A><BR>
<A href='?src=[UID()];make=9;dir=1'>Gas Pump</A><BR>
<A href='?src=[UID()];make=15;dir=1'>Passive Gate</A><BR>
<A href='?src=[UID()];make=16;dir=1'>Volume Pump</A><BR>
<A href='?src=[UID()];make=10;dir=1'>Scrubber</A><BR>
<A href='?src=[UID()];makemeter=1'>Meter</A><BR>
<A href='?src=[UID()];makegsensor=1'>Gas Sensor</A><BR>
<A href='?src=[UID()];make=13;dir=1'>Gas Filter</A><BR>
<A href='?src=[UID()];make=14;dir=1'>Gas Mixer</A><BR>
<A href='?src=[UID()];make=34;dir=1'>Air Injector</A><BR>
<A href='?src=[UID()];make=36;dir=1'>Dual-Port Vent Pump</A><BR>
<A href='?src=[UID()];make=37;dir=1'>Passive Vent</A><BR>
<b>Heat exchange:</b><BR>
<A href='?src=[UID()];make=2;dir=1'>Pipe</A><BR>
<A href='?src=[UID()];make=3;dir=5'>Bent Pipe</A><BR>
<A href='?src=[UID()];make=6;dir=1'>Junction</A><BR>
<A href='?src=[UID()];make=17;dir=1'>Heat Exchanger</A><BR>
<b>Insulated pipes:</b><BR>
<A href='?src=[UID()];make=11;dir=1'>Pipe</A><BR>
<A href='?src=[UID()];make=12;dir=5'>Bent Pipe</A><BR>

"}
//What number the make points to is in the define # at the top of construction.dm in same folder
//which for some reason couldn't just be left defined, so it could be used here, top kek

	var/datum/browser/popup = new(user, "pipedispenser", name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "pipedispenser")

/obj/machinery/pipedispenser/Topic(href, href_list)
	if(..() || unwrenched)
		return 1

	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["make"])
		if(!wait)
			var/p_type = text2num(href_list["make"])
			var/p_dir = text2num(href_list["dir"])
			var/obj/item/pipe/P = new (loc, pipe_type=p_type, dir=p_dir)
			P.update()
			P.add_fingerprint(usr)
			wait = 1
			spawn(10)
				wait = 0
	if(href_list["makemeter"])
		if(!wait)
			new /obj/item/pipe_meter(loc)
			wait = 1
			spawn(15)
				wait = 0
	if(href_list["makegsensor"])
		if(!wait)
			new /obj/item/pipe_gsensor(loc)
			wait = 1
			spawn(15)
				wait = 0

/obj/machinery/pipedispenser/attackby(var/obj/item/W as obj, var/mob/user as mob, params)
	add_fingerprint(usr)
	if(istype(W, /obj/item/pipe) || istype(W, /obj/item/pipe_meter) || istype(W, /obj/item/pipe_gsensor))
		to_chat(usr, "<span class='notice'>You put [W] back to [src].</span>")
		user.drop_item()
		qdel(W)
		return
	else if(istype(W, /obj/item/weapon/wrench))
		if(unwrenched==0)
			playsound(loc, W.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You begin to unfasten \the [src] from the floor...</span>")
			if(do_after(user, 40 * W.toolspeed, target = src))
				user.visible_message( \
					"[user] unfastens \the [src].", \
					"<span class='notice'>You have unfastened \the [src]. Now it can be pulled somewhere else.</span>", \
					"You hear ratchet.")
				anchored = 0
				stat |= MAINT
				unwrenched = 1
				if(usr.machine==src)
					usr << browse(null, "window=pipedispenser")
		else /*if(unwrenched==1)*/
			playsound(loc, W.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You begin to fasten \the [src] to the floor...</span>")
			if(do_after(user, 20 * W.toolspeed, target = src))
				user.visible_message( \
					"[user] fastens \the [src].", \
					"<span class='notice'>You have fastened \the [src]. Now it can dispense pipes.</span>", \
					"You hear ratchet.")
				anchored = 1
				stat &= ~MAINT
				unwrenched = 0
				power_change()
	else
		return ..()


/obj/machinery/pipedispenser/disposal
	name = "Disposal Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = 1
	anchored = 1.0

//Allow you to drag-drop disposal pipes into it
/obj/machinery/pipedispenser/disposal/MouseDrop_T(var/obj/structure/disposalconstruct/pipe, mob/usr)
	if(usr.incapacitated())
		return

	if(!istype(pipe) || get_dist(usr, src) > 1 || get_dist(src, pipe) > 1 )
		return

	if(pipe.anchored)
		return

	qdel(pipe)

/obj/machinery/pipedispenser/disposal/attack_hand(mob/user)
	if(..())
		return
		
	interact(user)
	
/obj/machinery/pipedispenser/disposal/attack_ghost(mob/user)
	interact(user)
	
/obj/machinery/pipedispenser/disposal/interact(mob/user)
	var/dat = {"<b>Disposal Pipes</b><br><br>
<A href='?src=[UID()];dmake=0'>Pipe</A><BR>
<A href='?src=[UID()];dmake=1'>Bent Pipe</A><BR>
<A href='?src=[UID()];dmake=2'>Junction</A><BR>
<A href='?src=[UID()];dmake=3'>Y-Junction</A><BR>
<A href='?src=[UID()];dmake=4'>Trunk</A><BR>
<A href='?src=[UID()];dmake=5'>Bin</A><BR>
<A href='?src=[UID()];dmake=6'>Outlet</A><BR>
<A href='?src=[UID()];dmake=7'>Chute</A><BR>
"}

	var/datum/browser/popup = new(user, "pipedispenser", name, 400, 400)
	popup.set_content(dat)
	popup.open()

/obj/machinery/pipedispenser/disposal/Topic(href, href_list)
	if(..() || unwrenched)
		return 1

	usr.set_machine(src)
	add_fingerprint(usr)

	if(!wait)
		var/p_type = text2num(href_list["dmake"])
		var/obj/structure/disposalconstruct/C = new (loc)
		switch(p_type)
			if(0)
				C.ptype = 0
			if(1)
				C.ptype = 1
			if(2)
				C.ptype = 2
			if(3)
				C.ptype = 4
			if(4)
				C.ptype = 5
			if(5)
				C.ptype = 6
				C.density = 1
			if(6)
				C.ptype = 7
				C.density = 1
			if(7)
				C.ptype = 8
				C.density = 1
		C.add_fingerprint(usr)
		C.update()
		wait = 1
		spawn(15)
			wait = 0