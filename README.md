# 🧬 HyperMelanopsin

**HyperMelanopsin** is a set of MATLAB scripts designed to compare visual encoding based on luminance, melanopsin excitation, and ipRGC (intrinsically photosensitive retinal ganglion cell) integration using hyperspectral images.

The project explores how different visual mechanisms respond to natural and artificial scenes, using publicly available hyperspectral data.

---

## ▶️ Main Scripts

- `Compare_groups.m`: Compares absolute values and contrast for luminance, melanopsin excitation, and ipRGC encoding across image groups.
- `Compare_sizes.m`: Evaluates differences between two receptive field sizes for ipRGCs.
- `Compare_groups_ips.m`: Compares results from ipRGC type 1 and type 2 encoding.
- `Plot_verification.m`: Verifies responses to artificial images with isolated melanopsin or luminance variations.
  
---

## 🛠️ Data Generation

All previous scripts rely on publicly available hyperspectral images of natural and man-made environments under daylight illumination, as published by Foster and Nascimento [[1](#references), [2](#references)].

These data can be preprocessed using:

- `Mel_stats_main.m`
- `create_artificial_scene_main.m`  
(located in the `generate_verification_hsi` folder)

---

## 📂 Additional Resources

Auxiliary functions included:

- `plotMean.m`
- `plotMean2.m` 
Provided by **Dr. Alexander Schuetz**.

---




---

## 🌐 Hyperspectral Image Database

**Nascimento, Amano & Foster (2016)**  
[Link to dataset](https://sites.google.com/view/sergionascimento/home/scientific-data/hyperspectral-images-for-spatial-distribution-of-local-illumination-2015)

> Nascimento, S. M. C., Amano, K. & Foster, D. H.  
> *Spatial distributions of local illumination color in natural scenes*.  
> Vision Research, 120, 39–44 (2016)

Hyperescpectral database: https://sites.google.com/view/sergionascimento/home/scientific-data/hyperspectral-images-for-spatial-distribution-of-local-illumination-2015.  Nascimento, Amano & Foster (2016) Spatial distributions of local illumination color in natural scenes, Vision Research.


![image](https://github.com/user-attachments/assets/2d1b3d12-bf22-4f78-8326-e3a90cc4ced2)
![image](https://github.com/user-attachments/assets/54717e5e-8102-433d-8c51-35d3ef5d5a16)
---

## 📚 References

1. Nascimento, S. M. C., Amano, K., & Foster, D. H. (2016). *Spatial distributions of local illumination color in natural scenes*. **Vision Research**, 120, 39–44.  

---

## 🧑‍💻 Authors
**Pablo A. Barrionuevo**
[GitHub Profile](https://github.com/pbarrionuevo)

**Francisco Díaz Barrancas**  
[GitHub Profile](https://github.com/francisco-diaz-barrancas)

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.





