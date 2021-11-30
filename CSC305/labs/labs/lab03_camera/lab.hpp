#pragma once

#include <atlas/core/Float.hpp>
#include <atlas/math/Math.hpp>
#include <atlas/math/Random.hpp>
#include <atlas/math/Ray.hpp>

#include <fmt/printf.h>
#include <stb_image.h>
#include <stb_image_write.h>

#include <limits>
#include <vector>

using atlas::core::areEqual;

using Colour = atlas::math::Vector;

void saveToFile(std::string const& filename,
                std::size_t width,
                std::size_t height,
                std::vector<Colour> const& image);

// Declarations
class Camera;
class Shape;
class Sampler;

struct ShadeRec
{
    Colour color;
    float t;
};

struct World
{
    std::size_t width, height;
    Colour background;
    std::shared_ptr<Sampler> sampler;
    std::vector<std::shared_ptr<Shape>> scene;
    std::vector<Colour> image;
};

// Abstract classes defining the interfaces for concrete entities

class Camera
{
public:
    Camera();

    virtual ~Camera() = default;

    virtual void renderScene(World& world) const = 0;

	void setEye(atlas::math::Point const& eye) {
		mEye = eye;
	}

	void setLookAt(atlas::math::Point const& lookAt) {
		mLookAt = lookAt;
	}

	void setUpVector(atlas::math::Vector const& up) {
		mUp = up;
	}

	void computeUVW() {
		mW = (mEye - mLookAt) / glm::abs((mEye - mLookAt);
		mU = (glm::cross(mUp, mW)) / glm::abs(glm::cross(mUp, mW));
	}

	void Pinhole::renderScene(World world) const {
		//create ray
		//set ray.o = meye

		//create points sample_point, pixel_point

		//for each row in image
			//for each column in image
			//create colour avg_color {0,0,0}
			//this will be used to aggregate samples in the end
			//divide it by numsamples to get the true average colour sampled

			//Create shaderec sr
			//either set its value to some 'infinity' value, or use a flag to track
			//if you,ve hit anything
			//std::numeric_limits<flaot>::max() gets max possible value of float, if u want to use it


			//for each sample you want to take
				//sample_point = world.sampler->sampleUnitSquare();
				//set pixel_point x and y to center of a pixel
				//add sample_point to pixel_point(to get true location of current sample)
				//set ray.d = normalize(pixel_point + sample_point)
				
				//for each object in scene
					object->hit(ray, sr);
				avg_colour = sr.color;//or background
			avg_colour /= world.sampler->get NumSamples();
			world.image.push_back(avg_colour);
	}	
protected:
    atlas::math::Point mEye;
    atlas::math::Point mLookAt;
    atlas::math::Point mUp;
    atlas::math::Vector mU, mV, mW;
};

class Sampler
{
public:
    Sampler(int numSamples, int numSets);
    virtual ~Sampler() = default;

    int getNumSamples() const;

    void setupShuffledIndeces();

    virtual void generateSamples() = 0;

    atlas::math::Point sampleUnitSquare();

protected:
    std::vector<atlas::math::Point> mSamples;
    std::vector<int> mShuffledIndeces;

    int mNumSamples;
    int mNumSets;
    unsigned long mCount;
    int mJump;
};

class Shape
{
public:
    Shape();
    virtual ~Shape() = default;

    // if t computed is less than the t in sr, it and the color should be updated in sr
    virtual bool hit(atlas::math::Ray<atlas::math::Vector> const& ray,
                     ShadeRec& sr) const = 0;

    void setColour(Colour const& col);

    Colour getColour() const;

protected:
    virtual bool intersectRay(atlas::math::Ray<atlas::math::Vector> const& ray,
                              float& tMin) const = 0;

    Colour mColour;
};

// Concrete classes which we can construct and use in our ray tracer

class Sphere : public Shape
{
public:
    Sphere(atlas::math::Point center, float radius);

    bool hit(atlas::math::Ray<atlas::math::Vector> const& ray,
             ShadeRec& sr) const;

private:
    bool intersectRay(atlas::math::Ray<atlas::math::Vector> const& ray,
                      float& tMin) const;

    atlas::math::Point mCentre;
    float mRadius;
    float mRadiusSqr;
};

class Regular : public Sampler
{
public:
    Regular(int numSamples, int numSets);

    void generateSamples();
};
