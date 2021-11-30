#include "assignment.hpp"

int main()
{	
	constexpr std::size_t image_Width{ 600 };
	constexpr std::size_t image_Height{ 600 };
	constexpr Colour background{ 0,0,0 };
	
	constexpr Sphere sph1 = { {600,100,10}, 60, {1,0,0}};
	constexpr Sphere sph2 = { {200,100,0} ,10, {2,4,0} };
	constexpr Sphere sph3 = {{800,400,50}, 40, {2,0,1} };
	constexpr Sphere sph4 = { {440,300,200}, 50, {1,6,1} };
	constexpr Sphere sph5 = { {1000,500,20}, 30, {0,1,0} };
	constexpr Sphere sph6 = { {400,1000,0}, 45, {2,2,2} };
	Sphere objects[6] = { sph1,sph2,sph3,sph4,sph5,sph6 };
	atlas::math::Ray<atlas::math::Vector> ray{ {0, 0, 0}, {0, 0, -1} };
	ShadeRec trace_data{};
	std::vector<Colour> image{ image_Width * image_Height };
	

	for (std::size_t y{ 0 }; y < image_Height; ++y)
	{
		for (std::size_t x{ 0 }; x < image_Width; ++x)
		{
			float minT = 1000000000.f;
			// set origin to present pixel
			ray.o = { x + 0.5f, y + 0.5f, 0 };

			// check if ray didn't hit the sphere
			Sphere closest = { {0,0,0},0,{0,0,0} };
			for (int k = 0; k < 6; ++k) {
				if (objects[k].hit(ray, trace_data)) {
					float intsec = trace_data.t;
					if (intsec < minT) {
						closest = objects[k];
						minT = intsec;
					}
				}
			}
			if (closest.getRadius() != 0 ) {
				image[x + y * image_Height] = closest.getColor();
			}
			else {
				image[x + y * image_Height] = background;
			}

		}
	}	
	saveToBMP("a1.bmp", image_Width, image_Height, image);

    return 0;
}

/**
 * Saves a BMP image file based on the given array of pixels. All pixel values
 * have to be in the range [0, 1].
 *
 * @param filename The name of the file to save to.
 * @param width The width of the image.
 * @param height The height of the image.
 * @param image The array of pixels representing the image.
 */
void saveToBMP(std::string const& filename,
               std::size_t width,
               std::size_t height,
               std::vector<Colour> const& image)
{
    std::vector<unsigned char> data(image.size() * 3);

    for (std::size_t i{0}, k{0}; i < image.size(); ++i, k += 3)
    {
        Colour pixel = image[i];
        data[k + 0]  = static_cast<unsigned char>(pixel.r * 255);
        data[k + 1]  = static_cast<unsigned char>(pixel.g * 255);
        data[k + 2]  = static_cast<unsigned char>(pixel.b * 255);
    }

    stbi_write_bmp(filename.c_str(),
                   static_cast<int>(width),
                   static_cast<int>(height),
                   3,
                   data.data());
}
