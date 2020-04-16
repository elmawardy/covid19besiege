<template>
  <div>
    <img
      style="width:300px;height:300px;"
      src="https://www.ephotopix.com/wp-content/uploads/2018/11/Egypt-Map.jpg"
      alt
    />
  </div>
</template>

<script>
export default {
  props: ["type", "country"]
};
</script>

<style>
path {
  fill: silver;
}

path.state:hover {
  stroke: rgb(50, 87, 57);
  fill: gray;
  cursor: pointer;
}
</style>
