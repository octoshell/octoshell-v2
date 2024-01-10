Core::Notice.where(active_legacy: 1).update_all(active: true)
