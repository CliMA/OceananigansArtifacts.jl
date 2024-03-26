using JLD2

function read_big_endian_coordinates(filename, Ninterior = 32, Nhalo = 1)
    # Open the file in binary read mode
    open(filename, "r") do io
        # Calculate the number of Float64 values in the file
        n = filesize(io) ÷ sizeof(Float64)

        # Ensure n = (Ninterior + 2 * Nhalo) * (Ninterior + 2 * Nhalo)
        if n != (Ninterior + 2 * Nhalo) * (Ninterior + 2 * Nhalo)
            error("File size does not match the expected size for an (Ninterior + 2 * Nhalo) x (Ninterior + 2 * Nhalo) field")
        end

        # Initialize an array to hold the data
        data = Vector{Float64}(undef, n)

        # Read the data into the array
        read!(io, data)

        # Convert from big-endian to native endianness
        native_data = reshape(bswap.(data), (Ninterior + 2 * Nhalo), (Ninterior + 2 * Nhalo))

        return native_data
    end
end

#####
##### Convert .bin files to .jld2
#####

cubed_sphere_filepath = "cubed_sphere_32_grid_with_4_halos.jld2"

Nx, Ny, Nz = 32, 32, 1
Hx, Hy = 4, 4

 λᶜᶜᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
 λᶠᶠᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
 φᶜᶜᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
 φᶠᶠᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Δxᶜᶜᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Δxᶠᶜᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Δxᶜᶠᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Δxᶠᶠᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Δyᶜᶜᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Δyᶠᶜᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Δyᶜᶠᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Δyᶠᶠᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Azᶜᶜᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Azᶠᶜᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Azᶜᶠᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Azᶠᶠᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)

for panel in 1:6
     λᶜᶜᵃ_parent[:, :, panel] =  read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/xC.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
     λᶠᶠᵃ_parent[:, :, panel] =  read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/xG.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
     φᶜᶜᵃ_parent[:, :, panel] =  read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/yC.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
     φᶠᶠᵃ_parent[:, :, panel] =  read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/yG.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
    Δxᶜᶜᵃ_parent[:, :, panel] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/dxF.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
    Δxᶠᶜᵃ_parent[:, :, panel] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/dXc.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
    Δxᶜᶠᵃ_parent[:, :, panel] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/dXg.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
    Δxᶠᶠᵃ_parent[:, :, panel] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/dxV.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
    Δyᶜᶜᵃ_parent[:, :, panel] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/dyF.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
    Δyᶠᶜᵃ_parent[:, :, panel] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/dYg.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
    Δyᶜᶠᵃ_parent[:, :, panel] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/dYc.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
    Δyᶠᶠᵃ_parent[:, :, panel] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/dyU.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
    Azᶜᶜᵃ_parent[:, :, panel] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/rAc.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
    Azᶠᶜᵃ_parent[:, :, panel] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/rAw.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
    Azᶜᶠᵃ_parent[:, :, panel] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/rAs.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
    Azᶠᶠᵃ_parent[:, :, panel] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/rAz.00$(panel).001.data", 32, 4)[1+4-Hx:end-4+Hx, 1+4-Hy:end-4+Hy]
end

jldopen(cubed_sphere_filepath, "w") do file
    for panel in 1:6
        file["panel" * string(panel) * "/λᶜᶜᵃ" ] =  λᶜᶜᵃ_parent[:, :, panel]
        file["panel" * string(panel) * "/λᶠᶠᵃ" ] =  λᶠᶠᵃ_parent[:, :, panel]
        file["panel" * string(panel) * "/φᶜᶜᵃ" ] =  φᶜᶜᵃ_parent[:, :, panel]
        file["panel" * string(panel) * "/φᶠᶠᵃ" ] =  φᶠᶠᵃ_parent[:, :, panel]
        file["panel" * string(panel) * "/Δxᶜᶜᵃ"] = Δxᶜᶜᵃ_parent[:, :, panel]
        file["panel" * string(panel) * "/Δxᶠᶜᵃ"] = Δxᶠᶜᵃ_parent[:, :, panel]
        file["panel" * string(panel) * "/Δxᶜᶠᵃ"] = Δxᶜᶠᵃ_parent[:, :, panel]
        file["panel" * string(panel) * "/Δxᶠᶠᵃ"] = Δxᶠᶠᵃ_parent[:, :, panel]
        file["panel" * string(panel) * "/Δyᶜᶜᵃ"] = Δyᶜᶜᵃ_parent[:, :, panel]
        file["panel" * string(panel) * "/Δyᶠᶜᵃ"] = Δyᶠᶜᵃ_parent[:, :, panel]
        file["panel" * string(panel) * "/Δyᶜᶠᵃ"] = Δyᶜᶠᵃ_parent[:, :, panel]
        file["panel" * string(panel) * "/Δyᶠᶠᵃ"] = Δyᶠᶠᵃ_parent[:, :, panel]
        file["panel" * string(panel) * "/Azᶜᶜᵃ"] = Azᶜᶜᵃ_parent[:, :, panel]
        file["panel" * string(panel) * "/Azᶠᶜᵃ"] = Azᶠᶜᵃ_parent[:, :, panel]
        file["panel" * string(panel) * "/Azᶜᶠᵃ"] = Azᶜᶠᵃ_parent[:, :, panel]
        file["panel" * string(panel) * "/Azᶠᶠᵃ"] = Azᶠᶠᵃ_parent[:, :, panel]
    end
end

@info "Generated $cubed_sphere_filepath"
