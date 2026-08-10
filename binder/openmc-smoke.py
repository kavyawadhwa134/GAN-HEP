#!/usr/bin/env python3
"""Create and run a tiny event-based OpenMC criticality problem."""

from __future__ import annotations

import openmc


fuel = openmc.Material(name="UO2 fuel")
fuel.set_density("g/cm3", 10.4)
fuel.add_nuclide("U235", 0.04)
fuel.add_nuclide("U238", 0.96)
fuel.add_nuclide("O16", 2.0)

water = openmc.Material(name="light water")
water.set_density("g/cm3", 1.0)
water.add_nuclide("H1", 2.0)
water.add_nuclide("O16", 1.0)

fuel_surface = openmc.ZCylinder(r=0.40)
outer_surface = openmc.ZCylinder(r=0.65, boundary_type="vacuum")

fuel_cell = openmc.Cell(fill=fuel, region=-fuel_surface)
water_cell = openmc.Cell(fill=water, region=+fuel_surface & -outer_surface)
geometry = openmc.Geometry([fuel_cell, water_cell])

settings = openmc.Settings()
settings.run_mode = "eigenvalue"
settings.event_based = True
settings.batches = 4
settings.inactive = 1
settings.particles = 1000
settings.source = openmc.Source(
    space=openmc.stats.Box(
        (-0.39, -0.39, -0.5),
        (0.39, 0.39, 0.5),
        only_fissionable=True,
    )
)

materials = openmc.Materials([fuel, water])
materials.export_to_xml()
geometry.export_to_xml()
settings.export_to_xml()
openmc.run(event_based=True)
