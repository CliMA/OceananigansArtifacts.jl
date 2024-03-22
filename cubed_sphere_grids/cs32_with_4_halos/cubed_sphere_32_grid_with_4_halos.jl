using JLD2

function read_big_endian_coordinates(filename, nInterior = 32, Nhalo = 1)
    # Open the file in binary read mode
    open(filename, "r") do io
        # Calculate the number of Float64 values in the file
        n = filesize(io) ÷ sizeof(Float64)

        # Ensure n = (nInterior + 2 * Nhalo) * (nInterior + 2 * Nhalo)
        if n != (nInterior + 2 * Nhalo) * (nInterior + 2 * Nhalo)
            error("File size does not match the expected size for one (nInterior + 2 * Nhalo) x (nInterior + 2 * Nhalo) field")
        end

        # Initialize an array to hold the data
        data = Vector{Float64}(undef, n)

        # Read the data into the array
        read!(io, data)

        # Convert from big-endian to native endianness
        native_data = reshape(bswap.(data), (nInterior + 2 * Nhalo), (nInterior + 2 * Nhalo))

        return native_data
    end
end

Nx, Ny, Nz = 32, 32, 1
Hx, Hy = 4, 4

λᶜᶜᵃ_parent  = zeros(Nx+2Hx, Ny+2Hy, 6)
λᶠᶠᵃ_parent  = zeros(Nx+2Hx, Ny+2Hy, 6)
φᶜᶜᵃ_parent  = zeros(Nx+2Hx, Ny+2Hy, 6)
φᶠᶠᵃ_parent  = zeros(Nx+2Hx, Ny+2Hy, 6)
Δxᶠᶜᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Δxᶜᶠᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Δyᶠᶜᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Δyᶜᶠᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Azᶜᶜᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Azᶠᶜᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Azᶜᶠᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)
Azᶠᶠᵃ_parent = zeros(Nx+2Hx, Ny+2Hy, 6)

for region in 1:6
    λᶜᶜᵃ_parent[:, :, region]  =  read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/xC.00$(region).001.data", 32, 4)[1+4-Hx:end-4+Hx,1+4-Hy:end-4+Hy]
    λᶠᶠᵃ_parent[:, :, region]  =  read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/xG.00$(region).001.data", 32, 4)[1+4-Hx:end-4+Hx,1+4-Hy:end-4+Hy]
    φᶜᶜᵃ_parent[:, :, region]  =  read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/yC.00$(region).001.data", 32, 4)[1+4-Hx:end-4+Hx,1+4-Hy:end-4+Hy]
    φᶠᶠᵃ_parent[:, :, region]  =  read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/yG.00$(region).001.data", 32, 4)[1+4-Hx:end-4+Hx,1+4-Hy:end-4+Hy]
    Δxᶠᶜᵃ_parent[:, :, region] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/dXc.00$(region).001.data", 32, 4)[1+4-Hx:end-4+Hx,1+4-Hy:end-4+Hy]
    Δxᶜᶠᵃ_parent[:, :, region] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/dXg.00$(region).001.data", 32, 4)[1+4-Hx:end-4+Hx,1+4-Hy:end-4+Hy]
    Δyᶠᶜᵃ_parent[:, :, region] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/dYg.00$(region).001.data", 32, 4)[1+4-Hx:end-4+Hx,1+4-Hy:end-4+Hy]
    Δyᶜᶠᵃ_parent[:, :, region] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/dYc.00$(region).001.data", 32, 4)[1+4-Hx:end-4+Hx,1+4-Hy:end-4+Hy]
    Azᶜᶜᵃ_parent[:, :, region] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/rAc.00$(region).001.data", 32, 4)[1+4-Hx:end-4+Hx,1+4-Hy:end-4+Hy]
    Azᶠᶜᵃ_parent[:, :, region] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/rAw.00$(region).001.data", 32, 4)[1+4-Hx:end-4+Hx,1+4-Hy:end-4+Hy]
    Azᶜᶠᵃ_parent[:, :, region] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/rAs.00$(region).001.data", 32, 4)[1+4-Hx:end-4+Hx,1+4-Hy:end-4+Hy]
    Azᶠᶠᵃ_parent[:, :, region] = read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/rAz.00$(region).001.data", 32, 4)[1+4-Hx:end-4+Hx,1+4-Hy:end-4+Hy]
end

cs32_grid_file_missing_metrics = jldopen("cubed_sphere_32_grid_with_4_halos_missing_metrics.jld2")

jldopen("cubed_sphere_32_grid_with_4_halos.jld2", "w") do file
    for region in 1:6
        file["face" * string(region) * "/λᶜᶜᵃ" ] =  λᶜᶜᵃ_parent[:, :, region]
        file["face" * string(region) * "/λᶠᶠᵃ" ] =  λᶠᶠᵃ_parent[:, :, region]
        file["face" * string(region) * "/φᶜᶜᵃ" ] =  φᶜᶜᵃ_parent[:, :, region]
        file["face" * string(region) * "/φᶠᶠᵃ" ] =  φᶠᶠᵃ_parent[:, :, region]
        file["face" * string(region) * "/Δxᶠᶜᵃ"] = Δxᶠᶜᵃ_parent[:, :, region]
        file["face" * string(region) * "/Δxᶜᶠᵃ"] = Δxᶜᶠᵃ_parent[:, :, region]
        file["face" * string(region) * "/Δyᶠᶜᵃ"] = Δyᶠᶜᵃ_parent[:, :, region]
        file["face" * string(region) * "/Δyᶜᶠᵃ"] = Δyᶜᶠᵃ_parent[:, :, region]
        file["face" * string(region) * "/Azᶜᶜᵃ"] = Azᶜᶜᵃ_parent[:, :, region]
        file["face" * string(region) * "/Azᶠᶜᵃ"] = Azᶠᶜᵃ_parent[:, :, region]
        file["face" * string(region) * "/Azᶜᶠᵃ"] = Azᶜᶠᵃ_parent[:, :, region]
        file["face" * string(region) * "/Azᶠᶠᵃ"] = Azᶠᶠᵃ_parent[:, :, region]
        # Fill the following metrics with their Oceananigans counterparts for now.
        file["face" * string(region) * "/Δxᶜᶜᵃ"] = cs32_grid_file_missing_metrics["face" * string(region) * "/Δxᶜᶜᵃ"]
        file["face" * string(region) * "/Δyᶜᶜᵃ"] = cs32_grid_file_missing_metrics["face" * string(region) * "/Δyᶜᶜᵃ"]
        file["face" * string(region) * "/Δxᶠᶠᵃ"] = cs32_grid_file_missing_metrics["face" * string(region) * "/Δxᶠᶠᵃ"]
        file["face" * string(region) * "/Δyᶠᶠᵃ"] = cs32_grid_file_missing_metrics["face" * string(region) * "/Δyᶠᶠᵃ"]
    end
end

close(cs32_grid_file_missing_metrics)
