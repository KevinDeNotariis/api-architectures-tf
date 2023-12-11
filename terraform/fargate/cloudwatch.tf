# ------------------------------------------------------------------------------------------
# Log Filters
#
# Log Pattern: [2023-12-05T08:27:04.903Z] info: GET /.env params={} body={}
#
# Log Expression: [timestamp, logLevel=%info%, httpMethod, requestPath, params, body]
# ------------------------------------------------------------------------------------------
locals {
  metric_filter_namespace = "${var.identifier}-${var.environment}-${var.suffix}/fargate"
}

resource "aws_cloudwatch_log_metric_filter" "web_path_enumerate" {
  name           = "${var.identifier}-${var.environment}-web-path-enumerate-${var.suffix}"
  pattern        = "[timestamp, logLevel=%info%, httpMethod=POST || httpMethod=GET, requestPath, params, body]"
  log_group_name = module.ecs.ecs_container_log_group_name

  metric_transformation {
    namespace = local.metric_filter_namespace
    name      = "SourcePaths"
    value     = "1"
    dimensions = {
      SourcePath = "$requestPath"
    }
  }
}

# ------------------------------------------------------------------------------------------
# Widgets definition
# ------------------------------------------------------------------------------------------
locals {
  x_offset = 0
  y_offset = 0

  total_width     = 24
  one_third_width = local.total_width / 3
  medium_height   = 4

  cloudwatch_dashboard_widgets = [
    local.dashboard_widgets_ecs_cluster_cpu_utilization,
    local.dashboard_widgets_ecs_cluster_memory_utilization,
    local.dashboard_widgets_ecs_cluster_disk_utilization,
    local.dashboard_widgets_ecs_cluster_task_count,
    local.dashboard_widgets_ecs_cluster_service_count,
    local.dashboard_widgets_ecs_cluster_network_bytes,
    local.dashboard_widgets_ecs_cluster_request_path_count,
    local.dashboard_widgets_ecs_cluster_request_methods_count,
    local.dashboard_widgets_ecs_cluster_request_ips_count
  ]
}

/*
  Widgets disposition:

  |-----------------| |--------------------| |------------------|
  | Cpu Utilization | | Memory Utilization | | Disk Utilization |
  |-----------------| |--------------------| |------------------|
  |-----------------| |--------------------| |------------------|
  | Task Count      | | Service Count      | | Network          |
  |-----------------| |--------------------| |------------------|
  |------------------------------||-----------------------------|
  |                              ||                             |
  |  Request Resource Paths      ||  Request Resource Methods   |
  |                              ||                             |
  |------------------------------||-----------------------------|
  |------------------------------|
  |                              |
  |  Request Resource IPs        |
  |                              |
  |------------------------------|

*/

locals {
  # -----------------------------------------------------------------------------
  # 1st Row
  # -----------------------------------------------------------------------------
  first_row_widget_width  = local.one_third_width
  first_row_widget_height = local.medium_height

  # ----------------------------------------------------
  # CPU Utilization
  # ----------------------------------------------------
  dashboard_widgets_ecs_cluster_cpu_utilization = {
    type   = "metric"
    x      = 0 + local.x_offset
    y      = 0 + local.y_offset
    width  = local.first_row_widget_width
    height = local.first_row_widget_height
    properties = {
      title  = "CPU Utilization"
      region = data.aws_region.current.name
      yAxis = {
        left = {
          min       = 0,
          showUnits = false,
          label     = "Percent"
        }
      }
      metrics = [
        [{
          label      = "${var.identifier}-${var.environment}-${var.suffix}"
          expression = "mm1m0  * 100 / mm0m0"
        }],
        ["ECS/ContainerInsights", "CpuReserved", "ClusterName", module.ecs.ecs_cluster_name, { period = 300, stat = "Sum", id = "mm0m0", visible = false }],
        [".", "CpuUtilized", ".", ".", { period = 300, stat = "Sum", id = "mm1m0", visible = false }]
      ]
      legend = {
        position = "bottom"
      }
    }
  }

  # ----------------------------------------------------
  # Memory Utilization
  # ----------------------------------------------------
  dashboard_widgets_ecs_cluster_memory_utilization = {
    type   = "metric"
    x      = local.first_row_widget_width + local.x_offset
    y      = 0 + local.y_offset
    width  = local.first_row_widget_width
    height = local.first_row_widget_height
    properties = {
      title  = "Memory Utilization"
      region = data.aws_region.current.name
      yAxis = {
        left = {
          min       = 0,
          showUnits = false,
          label     = "Percent"
        }
      }
      metrics = [
        [{
          label      = "${var.identifier}-${var.environment}-${var.suffix}"
          expression = "mm1m0  * 100 / mm0m0"
        }],
        ["ECS/ContainerInsights", "MemoryReserved", "ClusterName", module.ecs.ecs_cluster_name, { period = 300, stat = "Sum", id = "mm0m0", visible = false }],
        [".", "MemoryUtilized", ".", ".", { period = 300, stat = "Sum", id = "mm1m0", visible = false }]
      ]
      legend = {
        position = "bottom"
      }
    }
  }
  # ----------------------------------------------------
  # Disk Utilization
  # ----------------------------------------------------
  dashboard_widgets_ecs_cluster_disk_utilization = {
    type   = "metric"
    x      = local.first_row_widget_width * 2 + local.x_offset
    y      = 0 + local.y_offset
    width  = local.first_row_widget_width
    height = local.first_row_widget_height
    properties = {
      title  = "Disk Utilization"
      region = data.aws_region.current.name
      yAxis = {
        left = {
          min       = 0,
          showUnits = false,
          label     = "Percent"
        }
      }
      metrics = [
        [{
          label      = "${var.identifier}-${var.environment}-${var.suffix}"
          expression = "mm1m0  * 100 / mm0m0"
        }],
        ["ECS/ContainerInsights", "EphemeralStorageReserved", "ClusterName", module.ecs.ecs_cluster_name, { period = 300, stat = "Sum", id = "mm0m0", visible = false }],
        [".", "EphemeralStorageUtilized", ".", ".", { period = 300, stat = "Sum", id = "mm1m0", visible = false }]
      ]
      legend = {
        position = "bottom"
      }
    }
  }
  # -----------------------------------------------------------------------------
  # 2nd Row
  # -----------------------------------------------------------------------------
  second_row_widget_width  = local.one_third_width
  second_row_widget_height = local.medium_height

  # ----------------------------------------------------
  # Task Count
  # ----------------------------------------------------
  dashboard_widgets_ecs_cluster_task_count = {
    type   = "metric"
    x      = 0 + local.x_offset
    y      = local.first_row_widget_height + local.y_offset
    width  = local.second_row_widget_width
    height = local.second_row_widget_height
    properties = {
      title  = "Task Count"
      region = data.aws_region.current.name
      yAxis = {
        left = {
          min       = 0,
          showUnits = false,
          label     = "Count"
        }
      }
      metrics = [
        [{
          label      = "${var.identifier}-${var.environment}-${var.suffix}"
          expression = "mm0m0"
        }],
        ["ECS/ContainerInsights", "TaskCount", "ClusterName", module.ecs.ecs_cluster_name, { period = 300, stat = "Average", id = "mm0m0", visible = false }],
      ]
      legend = {
        position = "bottom"
      }
    }
  }

  # ----------------------------------------------------
  # Service Count
  # ----------------------------------------------------
  dashboard_widgets_ecs_cluster_service_count = {
    type   = "metric"
    x      = local.second_row_widget_width + local.x_offset
    y      = local.first_row_widget_height + local.y_offset
    width  = local.second_row_widget_width
    height = local.second_row_widget_height
    properties = {
      title  = "Task Count"
      region = data.aws_region.current.name
      yAxis = {
        left = {
          min       = 0,
          showUnits = false,
          label     = "Count"
        }
      }
      metrics = [
        [{
          label      = "${var.identifier}-${var.environment}-${var.suffix}"
          expression = "mm0m0"
        }],
        ["ECS/ContainerInsights", "TaskCount", "ClusterName", module.ecs.ecs_cluster_name, { period = 300, stat = "Average", id = "mm0m0", visible = false }],
      ]
      legend = {
        position = "bottom"
      }
    }
  }

  # ----------------------------------------------------
  # Network Bytes
  # ----------------------------------------------------
  dashboard_widgets_ecs_cluster_network_bytes = {
    type   = "metric"
    x      = local.second_row_widget_width * 2 + local.x_offset
    y      = local.first_row_widget_height + local.y_offset
    width  = local.second_row_widget_width
    height = local.second_row_widget_height
    properties = {
      title  = "Network"
      region = data.aws_region.current.name
      yAxis = {
        left = {
          min       = 0,
          showUnits = false,
          label     = "Bytes/Second"
        }
      }
      metrics = [
        [{
          label      = "${var.identifier}-${var.environment}-${var.suffix}"
          expression = "mm0m0 + mm1m0"
        }],
        ["ECS/ContainerInsights", "NetworkBytes", "ClusterName", module.ecs.ecs_cluster_name, { period = 300, stat = "Average", id = "mm0m0", visible = false }],
        [".", "NetworkTxBytes", ".", ".", { period = 300, stat = "Average", id = "mm1m0", visible = false }],
      ]
      legend = {
        position = "bottom"
      }
    }
  }

  # -----------------------------------------------------------------------------
  # 3rd Row
  # -----------------------------------------------------------------------------
  third_row_widget_width  = local.total_width / 2
  third_row_widget_height = local.medium_height * 2

  /*
    fields @timestamp, @message, @logStream, @log
    | filter @message LIKE /info/
    | parse @message "[*] * * * * *" as timestamp, logType, method, sourcePath, ip, rest
    | sort @timestamp desc
    | stats count(*) by sourcePath
  */
  dashboard_widgets_ecs_cluster_request_path_count = {
    type   = "log"
    x      = 0 + local.x_offset
    y      = local.first_row_widget_height + local.second_row_widget_height + local.y_offset
    width  = local.third_row_widget_width
    height = local.third_row_widget_height
    properties = {
      title  = "Application Request Paths"
      region = data.aws_region.current.name
      view   = "pie"
      stat   = "Sum"
      query  = "SOURCE '${module.ecs.ecs_container_log_group_name}' | fields @timestamp, @message, @logStream, @log\n| filter @message LIKE /info/\n| parse @message \"[*] * * * * *\" as timestamp, logType, method, sourcePath, ip, rest\n| sort @timestamp desc\n| stats count(*) by sourcePath"
    }
  }

  /*
    fields @timestamp, @message, @logStream, @log
    | filter @message LIKE /info/
    | parse @message "[*] * * * * *" as timestamp, logType, method, sourcePath, ip, rest
    | sort @timestamp desc
    | stats count(*) by method
  */
  dashboard_widgets_ecs_cluster_request_methods_count = {
    type   = "log"
    x      = local.third_row_widget_width + local.x_offset
    y      = local.first_row_widget_height + local.second_row_widget_height + local.y_offset
    width  = local.third_row_widget_width
    height = local.third_row_widget_height
    properties = {
      title  = "Application Request Methods"
      region = data.aws_region.current.name
      view   = "pie"
      stat   = "Sum"
      query  = "SOURCE '${module.ecs.ecs_container_log_group_name}' | fields @timestamp, @message, @logStream, @log\n| filter @message LIKE /info/\n| parse @message \"[*] * * * * *\" as timestamp, logType, method, sourcePath, ip, rest\n| sort @timestamp desc\n| stats count(*) by method"
    }
  }

  # -----------------------------------------------------------------------------
  # 4th Row
  # -----------------------------------------------------------------------------
  fourth_row_widget_width  = local.total_width / 2
  fourth_row_widget_height = local.medium_height * 2
  /*
    fields @timestamp, @message, @logStream, @log
    | filter @message LIKE /info/
    | parse @message "[*] * * * *" as timestamp, logType, method, sourcePath, rest
    | sort @timestamp desc
    | stats count(*) by method
  */
  dashboard_widgets_ecs_cluster_request_ips_count = {
    type   = "log"
    x      = local.x_offset
    y      = local.first_row_widget_height + local.second_row_widget_height + local.third_row_widget_height + local.y_offset
    width  = local.fourth_row_widget_width
    height = local.fourth_row_widget_height
    properties = {
      title  = "Application Request IPs"
      region = data.aws_region.current.name
      view   = "pie"
      stat   = "Sum"
      query  = "SOURCE '${module.ecs.ecs_container_log_group_name}' | fields @timestamp, @message, @logStream, @log\n| filter @message LIKE /info/\n| parse @message \"[*] * * * * *\" as timestamp, logType, method, sourcePath, ip, rest\n| sort @timestamp desc\n| stats count(*) by ip"
    }
  }
}
