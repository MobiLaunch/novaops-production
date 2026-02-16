#!/bin/bash

# Fix common Lucide icon name issues
find pages -name "*.vue" -type f -exec sed -i \
  -e 's/Banknotes/Banknote/g' \
  -e 's/TicketIcon/Ticket/g' \
  -e 's/CalendarIcon/Calendar/g' \
  {} +

echo "Icons fixed!"
