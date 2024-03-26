using JLD2

function read_big_endian_coordinates(filename, Ninterior = 32, Nhalo = 1)
    Nhalo > 4 && error("Nhalo must be ≤ 4")

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

        return native_data[1+4-Nhalo:end-4+Nhalo, 1+4-Nhalo:end-4+Nhalo]
    end
end

#####
##### Convert .bin files to .jld2
#####

cubed_sphere_filepath = "cubed_sphere_32_grid_with_4_halos.jld2"

N = Nx = Ny = 32
H = Hx = Hy = 4

vars = (:λᶜᶜᵃ, :λᶠᶠᵃ,
        :φᶜᶜᵃ, :φᶠᶠᵃ,
        :Δxᶜᶜᵃ, :Δxᶠᶜᵃ, :Δxᶜᶠᵃ, :Δxᶠᶠᵃ,
        :Δyᶜᶜᵃ, :Δyᶠᶜᵃ, :Δyᶜᶠᵃ, :Δyᶠᶠᵃ,
        :Azᶜᶜᵃ, :Azᶠᶜᵃ, :Azᶜᶠᵃ, :Azᶠᶠᵃ)

MITgcm_vars = (:xC, :xG,
               :yC, :yG,
               :dxF, :dXc, :dXg, :dxV,
               :dyF, :dYg, :dYc, :dyU,
               :rAc, :rAw, :rAs, :rAz)

for (var, MITgcm_var) in zip(vars, MITgcm_vars)
    # initialize vars with empty arrays
    eval(:($var = zeros(Nx + 2Hx, Ny + 2Hy, 6)))

    # populate every panel of var with data from .bin files
    MITgcm_var = string(MITgcm_var)
    for panel in 1:6
        expr = quote
            $var[:, :, $panel] =
                $read_big_endian_coordinates("cubed_sphere_32_grid_with_4_halos/" * $MITgcm_var * ".00" * string($panel) * ".001.data", $N, $H)
        end
        eval(expr)
    end
end

jldopen(cubed_sphere_filepath, "w") do file
    for panel in 1:6
        for var in vars
            var_name = string(var)
            expr = quote
                $file["panel" * string($panel) * "/" * $var_name] = $var[:, :, $panel]
            end
            eval(expr)
        end
    end
end

@info "Generated $cubed_sphere_filepath"
