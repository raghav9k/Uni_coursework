#pragma once
#include <algorithm>

#include <atlas/core/Float.hpp>
#include <atlas/math/Math.hpp>
#include <atlas/math/Random.hpp>
#include <atlas/math/Ray.hpp>

#include <fmt/printf.h>
#include <stb_image.h>
#include <stb_image_write.h>

#include <limits>
#include <vector>
#include <memory>

using atlas::core::areEqual;
using Colour = atlas::math::Vector;
using Colour = atlas::math::Vector;

void saveToFile(std::string const& filename,
	std::size_t width,
	std::size_t height,
	std::vector<Colour> const& image);

// Declarations
class Camera;
class Shape;
class Sampler;
class BRDF;
class Material;
class Light;


struct World
{
	std::size_t width, height;
	Colour background;
	std::shared_ptr<Sampler> sampler;
	std::vector<std::shared_ptr<Shape>> scene;
	std::vector<Colour> image;
	std::vector<std::shared_ptr<Light>> lights;
	std::shared_ptr<Light> ambient;
};


struct ShadeRec
{
	Colour color;
	float t;
	atlas::math::Normal normal;
	atlas::math::Ray<atlas::math::Vector> ray;
	std::shared_ptr<Material> material;
	std::shared_ptr<World> world;
};

// Abstract classes defining the interfaces for concrete entities

class Camera
{
public:
	Camera();

	virtual ~Camera() = default;

	virtual void renderScene(std::shared_ptr<World> world) const = 0;

	void setEye(atlas::math::Point const& eye);

	void setLookAt(atlas::math::Point const& lookAt);

	void setUpVector(atlas::math::Vector const& up);

	void computeUVW();

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

	void setMaterial(std::shared_ptr<Material> const& material);

	std::shared_ptr<Material> getMaterial() const;

protected:
	virtual bool intersectRay(atlas::math::Ray<atlas::math::Vector> const& ray,
		float& tMin) const = 0;

	Colour mColour;
	std::shared_ptr<Material> mMaterial;
};

class BRDF
{
public:
	virtual ~BRDF() = default;

	virtual Colour fn(ShadeRec const& sr,
		atlas::math::Vector const& reflected,
		atlas::math::Vector const& incoming) const = 0;
	virtual Colour rho(ShadeRec const& sr,
		atlas::math::Vector const& reflected) const = 0;
};

class Material
{
public:
	virtual ~Material() = default;

	virtual Colour shade(ShadeRec& sr) = 0;
};

class Light
{
public:
	virtual atlas::math::Vector getDirection(ShadeRec& sr) = 0;

	virtual Colour L(ShadeRec& sr);

	void scaleRadiance(float b);

	void setColour(Colour const& c);

protected:
	Colour mColour;
	float mRadiance;
};

// Concrete classes which we can construct and use in our ray tracer

class Triangle : public Shape
{
public:
	Triangle(atlas::math::Point v0, atlas::math::Point v1, atlas::math::Point v2);

	bool hit(atlas::math::Ray<atlas::math::Vector> const& ray, ShadeRec& sr) const;


private:
	bool intersectRay(atlas::math::Ray<atlas::math::Vector> const& ray, float& tMin) const;

	atlas::math::Point v0, v1, v2;
	atlas::math::Normal n;
};

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


class Plane : public Shape
{
public:
	Plane(atlas::math::Point p, atlas::math::Normal n);

	bool hit(atlas::math::Ray<atlas::math::Vector> const& ray,
		ShadeRec& sr) const;

private:
	bool intersectRay(atlas::math::Ray<atlas::math::Vector> const& ray,
		float& tMin) const;

	atlas::math::Point p;
	atlas::math::Normal n;
	double kEpsilon = 0.00001f;
};


class Pinhole : public Camera
{
public:
	Pinhole();

	void setDistance(float distance);
	void setZoom(float zoom);

	atlas::math::Vector rayDirection(atlas::math::Point const& p) const;
	void renderScene(std::shared_ptr<World> world) const;

private:
	float mDistance;
	float mZoom;
};

class Regular : public Sampler
{
public:
	Regular(int numSamples, int numSets);

	void generateSamples();
};

class Random : public Sampler
{
public:
	Random(int numSamples, int numSets);

	void generateSamples();
};

class Jittered : public Sampler
{
public:
	Jittered(int sumSamples, int numSets);

	void generateSamples();
};

class Lambertian : public BRDF
{
public:
	Lambertian();
	Lambertian(Colour diffuseColor, float diffuseReflection);

	Colour fn(ShadeRec const& sr,
		atlas::math::Vector const& reflected,
		atlas::math::Vector const& incoming) const override;

	Colour rho(ShadeRec const& sr,
		atlas::math::Vector const& reflected) const override;

	void setDiffuseReflection(float kd);

	void setDiffuseColour(Colour const& colour);

private:
	Colour mDiffuseColour;
	float mDiffuseReflection;
};

class Matte : public Material
{
public:
	Matte();
	Matte(float kd, float ka, Colour color);

	void setDiffuseReflection(float k);

	void setAmbientReflection(float k);

	void setDiffuseColour(Colour colour);

	Colour shade(ShadeRec& sr) override;

private:
	std::shared_ptr<Lambertian> mDiffuseBRDF;
	std::shared_ptr<Lambertian> mAmbientBRDF;
};

class Directional : public Light
{
public:
	Directional();
	Directional(atlas::math::Vector const& d);

	void setDirection(atlas::math::Vector const& d);

	atlas::math::Vector getDirection(ShadeRec& sr) override;

private:
	atlas::math::Vector mDirection;
};

class Ambient : public Light
{
public:
	Ambient();

	atlas::math::Vector getDirection(ShadeRec& sr) override;

private:
	atlas::math::Vector mDirection;
};

class Pointlight : public Light
{
public:
	Pointlight();
	Pointlight(atlas::math::Vector const& d);
	void setLocation(atlas::math::Vector const& d);

	atlas::math::Vector getDirection(ShadeRec& sr) override;

private:
	atlas::math::Vector mLocation;
};
