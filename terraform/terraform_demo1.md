
```js
// # Required variables - change them for every new setup of multi brand env
locals {
  workspace_brands_mapping = {
    // # <workspace> = [<brand_1>, <brand_2>]
    fr-stg-teamworkretail-uqeu-1a = ["uquk", "uqfr", "uqdk", "uqnl", "uqde", "uqes", "uqpl", "uqbe"]
    fr-stg-teamworkretail-uqeu-2a = ["uquk", "uqfr", "uqdk", "uqnl", "uqde", "uqes", "uqpl", "uqbe"]
    fr-stg-teamworkretail-uqeu-1b = ["uquk", "uqfr", "uqdk", "uqnl", "uqde", "uqes", "uqbe"]
    fr-stg-teamworkretail-uqeu-2b = ["uquk", "uqfr", "uqdk", "uqnl", "uqde", "uqes", "uqbe"]
    fr-stg-teamworkretail-uqeu-1d = ["uquk", "uqfr", "uqdk", "uqnl", "uqde", "uqes", "uqpl", "uqbe", "uqse", "uqit", "uqlu"]
    fr-stg-teamworkretail-uqeu-2d = ["uquk", "uqfr", "uqdk", "uqnl", "uqde", "uqes", "uqpl", "uqbe", "uqse", "uqit", "uqlu"]
    fr-prd-teamworkretail-uqeu-1a = ["uquk", "uqfr", "uqdk", "uqnl", "uqde", "uqes", "uqpl", "uqbe"]
    fr-prd-teamworkretail-uqeu-2a = ["uquk", "uqfr", "uqdk", "uqnl", "uqde", "uqes", "uqpl", "uqbe"]
    fr-prd-teamworkretail-uqeu-1b = ["uquk", "uqfr", "uqdk", "uqnl", "uqde", "uqes", "uqbe"]
    fr-prd-teamworkretail-uqeu-2b = ["uquk", "uqfr", "uqdk", "uqnl", "uqde", "uqes", "uqbe"]
    fr-prd-teamworkretail-uqeu-1d = ["uquk", "uqfr", "uqdk", "uqnl", "uqde", "uqes", "uqpl", "uqbe", "uqse", "uqit", "uqlu"]
    fr-prd-teamworkretail-uqeu-2d = ["uquk", "uqfr", "uqdk", "uqnl", "uqde", "uqes", "uqpl", "uqbe", "uqse", "uqit", "uqlu"]
  }

  brands = toset([
    for brand in local.workspace_brands_mapping[terraform.workspace] : lower(brand)
  ])

  sql_disk_brand_exclusion_list = toset(try([for key, value in local.instance_sql[terraform.workspace].brand_datadisk_size : key if value == -1], []))
  sql_disk_brands = setsubtract(local.brands, local.sql_disk_brand_exclusion_list)
}

// # K8s load balancer variables
locals {
  url_template = "${local.env}-${local.env_suffix}-teamwork-%s-%s.fastretailing.com"
}

// # This section related to number of disks for mssql VMs
locals {
  // # variable structure: [ {all brands with same i(i equal to array position index)}, {...}, ... ]
  sql_disk_info_indexed = [
    for i in range(local.instance_sql_num) : {
      for b in local.sql_disk_brands :
      "${b}-${i}" => {   //3  "${b}-${i}" 就是最终的key, 以下的body 都是value
        index = i   //1   index 就是0 or 1
        brand = b   //2   brand 是 "uquk", "uqfr", "uqdk", "uqnl", "uqde", "uqes", "uqbe"
        size  = try(local.instance_sql[terraform.workspace].brand_datadisk_size[b], local.instance_sql[terraform.workspace].datadisk_size)
      }
    }
  ]
  // # Expanding list of maps to create single map with all keys
  // # variable structure: {all brands and all i}
  // # https://www.terraform.io/docs/language/expressions/function-calls.html#expanding-function-arguments
  sql_disk_info = merge(local.sql_disk_info_indexed...)
}

```


```js
resource "google_compute_instance" "sql" {
  count = local.instance_sql_num

  name = "${local.region_name}-${local.brand_region}-sql-${local.env_suffix}-${count.index + 1}"

  machine_type = lookup(local.instance_sql[terraform.workspace], "machine_type")
  zone         = data.google_compute_zones.frk.names[count.index]

  tags = ["all-common-backup-server", "all-dc-servers", "all-${google_project.fr_teamworkretail.project_id}"]

  labels = {
    systemid    = local.systemid
    subsystemid = local.subsystemid
    scheduler   = local.stg_only == 1 ? (count.index == 0 ? "p1" : "p2") : "off"
  }

  boot_disk {
    auto_delete = false
    source      = google_compute_disk.sql.*.self_link[count.index]
  }

  dynamic "attached_disk" { //4
    for_each = local.sql_disk_info_indexed[count.index]
    content {
      device_name = "persistent-disk-${attached_disk.value.brand}"   //4 attached_disk就是指自己  //2 value.brand
      source      = google_compute_disk.sql_data[attached_disk.key].self_link   //3 key source 最终呈现形式 google_compute_disk.sql_data["uqbe-0"] { ....... }
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.sql.*.self_link[count.index]
    network_ip = google_compute_address.sql.*.address[count.index]
    access_config {}

    // # alias_ip_range {
    // #   ip_cidr_range = element(local.address_sql_alias_ip_range[terraform.workspace], count.index)
    // # }

    alias_ip_range {
      subnetwork_range_name = local.subnet_frk_sql_alias[terraform.workspace][count.index][0]
      ip_cidr_range         = local.subnet_frk_sql_alias[terraform.workspace][count.index][1]
    }
  }

  service_account {
    email = data.google_compute_default_service_account.default.email

    scopes = [
      "logging-write",
      "monitoring-write",
    ]
  }

  scheduling {
    preemptible         = false
    on_host_maintenance = "MIGRATE"
  }

  allow_stopping_for_update = true

  lifecycle {
    ignore_changes = ["metadata"]
  }
}
```