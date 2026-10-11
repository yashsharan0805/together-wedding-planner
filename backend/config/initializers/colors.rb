# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

Chroma.define_palette :decreasing_saturation do
  spin(20).desaturate(40)
  spin(-20).desaturate(40)
  spin(40).desaturate(40)
  spin(-40).desaturate(40)
end
