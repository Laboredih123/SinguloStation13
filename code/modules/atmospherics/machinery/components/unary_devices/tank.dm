#define AIR_CONTENTS	((25*ONE_ATMOSPHERE)*(air_contents.return_volume())/(R_IDEAL_GAS_EQUATION*air_contents.return_temperature()))
/obj/machinery/atmospherics/components/unary/tank
	icon = 'icons/obj/atmospherics/pipes/pressure_tank.dmi'
	icon_state = "generic"

	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."

	max_integrity = 800
	density = TRUE
	layer = ABOVE_WINDOW_LAYER
	pipe_flags = PIPING_ONE_PER_TURF

	var/volume = 10000 //in liters
	var/gas_type = 0

	pipe_state = "ptank"

/obj/machinery/atmospherics/components/unary/tank/New()
	..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_volume(volume)
	air_contents.set_temperature(T20C)
	if(gas_type)
		air_contents.set_moles(gas_type, AIR_CONTENTS)
		name = "[name] ([GLOB.meta_gas_info[gas_type][META_GAS_NAME]])"
	setPipingLayer(piping_layer)

/obj/machinery/atmospherics/components/unary/tank/Destroy() //Singulostation Edit Start - More devices.
	var/datum/gas_mixture/air_contents = airs[1]
	if(air_contents)
		var/turf/T = loc
		T.assume_air(air_contents)
		air_update_turf()
	..()

/obj/machinery/atmospherics/components/unary/tank/welder_act(mob/living/user, obj/item/I)
	..()
	if(user.a_intent == INTENT_HELP)
		if(obj_integrity <= max_integrity)
			if(!I.tool_start_check(user, amount=0))
				return
			to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
			if(I.use_tool(src, user, 40, volume=50))
				obj_integrity = max_integrity
				to_chat(user, "<span class='notice'>You repair [src].</span>")
		else
			to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
		return
	else //Copied from atmosmachinery and edited a bit since I didn't like it saying unwrenching when you clearly are slicing
		var/datum/gas_mixture/int_air = airs[1]
		var/datum/gas_mixture/env_air = loc.return_air()
		add_fingerprint(user)

		var/unsafe_slicing = FALSE
		var/internal_pressure = int_air.return_pressure()-env_air.return_pressure()

		to_chat(user, "<span class='notice'>You begin to slice apart \the [src]...</span>")

		if (internal_pressure > 2*ONE_ATMOSPHERE)
			to_chat(user, "<span class='warning'>As you begin slicing \the [src] a gush of air blows in your face... maybe you should reconsider?</span>")
			unsafe_slicing = TRUE //hehee

		if(I.use_tool(src, user, 60, volume=50))
			Destroy()
			user.visible_message( \
				"[user] slices \the [src].", \
				"<span class='notice'>You slice \the [src].</span>", \
				"<span class='hear'>You hear welding.</span>")
			investigate_log("was <span class='warning'>REMOVED</span> by [key_name(usr)]", INVESTIGATE_ATMOS)

			//Damn bruh you really sliced apart a 1+ GPa tank? Can't let you off the hook
			if(unsafe_slicing)
				unsafe_pressure_release(user, internal_pressure)

	return TRUE //Singulostation Edit End - More devices.

/obj/machinery/atmospherics/components/unary/tank/air
	icon_state = "grey"
	name = "pressure tank (Air)"

/obj/machinery/atmospherics/components/unary/tank/air/New()
	..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(/datum/gas/oxygen, AIR_CONTENTS * 0.2)
	air_contents.set_moles(/datum/gas/nitrogen, AIR_CONTENTS * 0.8)

/obj/machinery/atmospherics/components/unary/tank/carbon_dioxide
	gas_type = /datum/gas/carbon_dioxide

/obj/machinery/atmospherics/components/unary/tank/toxins
	icon_state = "orange"
	gas_type = /datum/gas/plasma

/obj/machinery/atmospherics/components/unary/tank/oxygen
	icon_state = "blue"
	gas_type = /datum/gas/oxygen

/obj/machinery/atmospherics/components/unary/tank/nitrogen
	icon_state = "red"
	gas_type = /datum/gas/nitrogen
